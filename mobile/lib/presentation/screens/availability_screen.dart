import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../providers/doctor_providers.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../data/models/doctor_detail_model.dart';

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final schedulesAsync = ref.watch(doctorSchedulesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(doctorSchedulesProvider.future),
        child: schedulesAsync.when(
          data: (schedules) => schedules.isEmpty
              ? _buildEmptyState(context, textTheme)
              : _buildScheduleList(context, textTheme, schedules),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildErrorState(context, textTheme, ref, err),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleBottomSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ), // Index 2 is Availability for Doctors
    );
  }

  void _showAddScheduleBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddScheduleBottomSheet(ref: ref),
    );
  }

  Widget _buildEmptyState(BuildContext context, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Working Hours Set',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Define your weekly availability so patients can book appointments with you.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(
    BuildContext context,
    TextTheme textTheme,
    List<DoctorSchedule> schedules,
  ) {
    // Sort by day of week
    final sortedSchedules = [...schedules]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sortedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = sortedSchedules[index];
        return _buildScheduleCard(context, textTheme, schedule);
      },
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    TextTheme textTheme,
    DoctorSchedule schedule,
  ) {
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final dayName = days[schedule.dayOfWeek];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.access_time_filled,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${schedule.slotDuration} min per session',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    TextTheme textTheme,
    WidgetRef ref,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load schedules',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(doctorSchedulesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddScheduleBottomSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddScheduleBottomSheet({required this.ref});

  @override
  State<_AddScheduleBottomSheet> createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<_AddScheduleBottomSheet> {
  int _dayOfWeek = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _duration = 30;
  bool _isLoading = false;

  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        'dayOfWeek': _dayOfWeek.toString(),
        'startTime': _formatTime(_startTime),
        'endTime': _formatTime(_endTime),
        'duration': _duration,
      };

      await widget.ref.read(doctorRepositoryProvider).addDoctorSchedule(payload);

      if (mounted) {
        widget.ref.invalidate(doctorSchedulesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Working Hour',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Select Day',
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                items: List.generate(
                  7,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(_days[i]),
                  ),
                ),
                onChanged: (v) => setState(() => _dayOfWeek = v!),
                decoration: _inputDecoration(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSection(
                    'Start Time',
                    InkWell(
                      onTap: () => _selectTime(true),
                      child: InputDecorator(
                        decoration: _inputDecoration(prefixIcon: Icons.access_time),
                        child: Text(_formatTime(_startTime)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    'End Time',
                    InkWell(
                      onTap: () => _selectTime(false),
                      child: InputDecorator(
                        decoration: _inputDecoration(prefixIcon: Icons.access_time),
                        child: Text(_formatTime(_endTime)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Session Duration (Minutes)',
              DropdownButtonFormField<int>(
                value: _duration,
                items: [15, 20, 30, 45, 60]
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text('$d minutes'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _duration = v!),
                decoration: _inputDecoration(prefixIcon: Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({IconData? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
