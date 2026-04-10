import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../providers/booking_providers.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  final String date;
  final String startTime;
  final String doctorProfileId;
  final String doctorName;

  const BookingFormScreen({
    super.key,
    required this.date,
    required this.startTime,
    required this.doctorProfileId,
    required this.doctorName,
  });

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _reasons = [
    'General Consultation',
    'Follow-up visit',
    'Medical Checkup/Control',
    'Prescription Renewal',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController.text = _reasons[0];
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleBooking() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for the visit')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final bookingId = await repo.createAppointment(
        date: widget.date,
        startTime: widget.startTime,
        reason: _reasonController.text,
        notes: _notesController.text,
        doctorProfileId: widget.doctorProfileId,
      );

      // Refresh the list
      ref.invalidate(bookingsProvider);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              Text(
                'Booking Successful!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Your appointment has been scheduled.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'View Booking Details',
                  onPressed: () {
                    context.go('/booking-details/$bookingId');
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/bookings'),
                child: const Text('Go to My Bookings'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(widget.date));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(Icons.person_outline, 'Doctor', widget.doctorName, textTheme),
                  const Divider(height: 24),
                  _buildSummaryRow(Icons.calendar_today_outlined, 'Date', formattedDate, textTheme),
                  const Divider(height: 24),
                  _buildSummaryRow(Icons.access_time, 'Time', widget.startTime, textTheme),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'APPOINTMENT DETAILS',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.outlineVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Reason Dropdown
            Text(
              'Reason for Visit',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _reasonController.text,
                  isExpanded: true,
                  items: _reasons.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _reasonController.text = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes field
            CustomTextField(
              label: 'Additional Notes (Optional)',
              controller: _notesController,
              hintText: 'e.g. Symptoms, current medications...',
              maxLines: 4,
            ),
            const SizedBox(height: 48),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: 'Confirm and Book',
                    icon: Icons.check,
                    onPressed: _handleBooking,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            Text(
              value,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
