import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../providers/search_providers.dart';

class SlotSelectionBottomSheet extends ConsumerStatefulWidget {
  final String doctorProfileId;
  final String doctorName;

  const SlotSelectionBottomSheet({
    super.key,
    required this.doctorProfileId,
    required this.doctorName,
  });

  @override
  ConsumerState<SlotSelectionBottomSheet> createState() => _SlotSelectionBottomSheetState();
}

class _SlotSelectionBottomSheetState extends ConsumerState<SlotSelectionBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    // Force a fresh fetch each time the bottom sheet is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      ref.invalidate(doctorSlotsProvider(DoctorSlotParams(
        doctorProfileId: widget.doctorProfileId,
        date: dateStr,
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    final slotsAsync = ref.watch(doctorSlotsProvider(DoctorSlotParams(
      doctorProfileId: widget.doctorProfileId,
      date: dateStr,
    )));

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Check Availability',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred date and time for ${widget.doctorName}',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Date Selection
          Text(
            'SELECT DATE',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.outlineVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.onSurface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _selectedSlot = null; // Reset slot when date changes
                });
                // Force fresh fetch for the newly selected date
                final dateStr = DateFormat('yyyy-MM-dd').format(picked);
                ref.invalidate(doctorSlotsProvider(DoctorSlotParams(
                  doctorProfileId: widget.doctorProfileId,
                  date: dateStr,
                )));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.outlineVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Slots Selection
          Text(
            'AVAILABLE SLOTS',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.outlineVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          slotsAsync.when(
            data: (result) {
              if (result.availableSlots.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy_outlined,
                          size: 32,
                          color: AppColors.error.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Not on Schedule',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor ${widget.doctorName} does not have a schedule configured for this date. Please select another day.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: result.availableSlots.map((slot) {
                  final isUnavailable = result.unavailableSlots.contains(slot);
                  final isSelected = _selectedSlot == slot;
                  
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    onSelected: isUnavailable ? null : (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    disabledColor: AppColors.surfaceContainerLow,
                    backgroundColor: AppColors.surfaceContainerLow,
                    labelStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                        ? Colors.white 
                        : (isUnavailable ? AppColors.outlineVariant : AppColors.onSurface),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected 
                          ? AppColors.primary 
                          : AppColors.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load slots',
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please check your connection and try again.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.invalidate(doctorSlotsProvider),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSlot == null 
                ? null 
                : () {
                    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                    context.push(
                      '/booking-form',
                      extra: {
                        'date': dateStr,
                        'startTime': _selectedSlot,
                        'doctorProfileId': widget.doctorProfileId,
                        'doctorName': widget.doctorName,
                      },
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Proceed to Booking',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _selectedSlot == null ? AppColors.outlineVariant : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
