import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medisify/presentation/providers/auth_providers.dart';
import '../../core/theme/app_colors.dart';
import '../providers/booking_providers.dart';
import '../providers/doctor_providers.dart';
import '../../data/models/booking_model.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailsProvider(bookingId));
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authProvider);
    final role = authState is AuthAuthenticated
        ? authState.user.role
        : 'PATIENT';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/bookings');
            }
          },
        ),
        title: Text(
          'Booking Details',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(bookingDetailsProvider(bookingId)),
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status
              _buildStatusHeader(booking, textTheme),
              const SizedBox(height: 32),

              // Appointment Info Section
              _buildSectionTitle('APPOINTMENT INFO', textTheme),
              const SizedBox(height: 16),
              _buildInfoCard(booking, textTheme),
              const SizedBox(height: 32),

              // Participant Section
              if (role == 'DOCTOR') ...[
                _buildSectionTitle('PATIENT', textTheme),
                const SizedBox(height: 16),
                _buildPatientCard(booking.patient, textTheme),
              ] else ...[
                _buildSectionTitle('DOCTOR', textTheme),
                const SizedBox(height: 16),
                _buildDoctorCard(booking.doctor, textTheme),
              ],
              const SizedBox(height: 32),

              // Details
              if (booking.reason != null || booking.notes != null) ...[
                _buildSectionTitle('REASON & NOTES', textTheme),
                const SizedBox(height: 16),
                _buildDetailsCard(booking, textTheme),
                const SizedBox(height: 32),
              ],

              // Timeline Section
              _buildSectionTitle('STATUS TIMELINE', textTheme),
              const SizedBox(height: 16),
              _buildTimeline(booking.statusTimeline, textTheme),

              const SizedBox(height: 48),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load booking details'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(bookingDetailsProvider(bookingId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bookingAsync.when(
        data: (booking) {
          final isPending = booking.currentStatus == 'PENDING';
          final isConfirmed = booking.currentStatus == 'CONFIRMED';
          final showCancel = isPending; // Both roles can cancel if pending
          final showConfirm = role == 'DOCTOR' && isPending;
          final showComplete = role == 'DOCTOR' && isConfirmed;

          if (!showCancel && !showConfirm && !showComplete) return null;

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showConfirm)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showStatusUpdateBottomSheet(
                        context,
                        ref,
                        bookingId,
                        'CONFIRMED',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Appointment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (showComplete)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showStatusUpdateBottomSheet(
                        context,
                        ref,
                        bookingId,
                        'COMPLETED',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Complete Appointment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (showConfirm) const SizedBox(height: 12),
                if (showCancel)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showCancelModal(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel Appointment',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _showCancelModal(BuildContext context, WidgetRef ref) {
    final noteController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cancel Appointment',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Please provide a reason for cancelling this appointment.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'e.g. Doctor is on sickday / I have another urgent matter',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (noteController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a cancellation note'),
                      ),
                    );
                    return;
                  }

                  try {
                    await ref
                        .read(bookingRepositoryProvider)
                        .cancelAppointment(bookingId, noteController.text);

                    if (!context.mounted) return;
                    Navigator.pop(context); // Close bottom sheet

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Icon(
                          Icons.check_circle,
                          color: AppColors.error,
                          size: 48,
                        ),
                        content: const Text(
                          'Your appointment has been successfully cancelled.',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Refresh all relevant providers
                              ref.invalidate(bookingsProvider);
                              ref.invalidate(nearestAppointmentProvider);
                              ref.invalidate(doctorAppointmentsProvider);
                              ref.invalidate(doctorInsightsProvider);
                              ref.invalidate(bookingDetailsProvider(bookingId));

                              Navigator.pop(context); // Close dialog
                              context.go('/bookings'); // Navigate to list
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Cancellation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Booking booking, TextTheme textTheme) {
    Color statusColor;
    switch (booking.currentStatus) {
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'CONFIRMED':
        statusColor = Colors.blue;
        break;
      case 'COMPLETED':
        statusColor = Colors.green;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.onSurfaceVariant;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status',
                style: textTheme.labelSmall?.copyWith(
                  color: statusColor.withValues(alpha: 0.8),
                ),
              ),
              Text(
                booking.currentStatus,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.outlineVariant,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoCard(Booking booking, TextTheme textTheme) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Date',
            dateFormat.format(booking.date),
            textTheme,
          ),
          const Divider(height: 32),
          _buildInfoRow(
            Icons.access_time,
            'Time',
            '${booking.startTime} - ${booking.endTime}',
            textTheme,
          ),
          const Divider(height: 32),
          _buildInfoRow(
            Icons.code,
            'Booking ID',
            '#${booking.id.substring(0, 8).toUpperCase()}',
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BookingDoctor? doctor, TextTheme textTheme) {
    if (doctor == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctor.specialty ?? 'General',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BookingPatient? patient, TextTheme textTheme) {
    if (patient == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (patient.phoneNumber != null)
                      Text(
                        patient.phoneNumber!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (patient.bloodType != null ||
              patient.height != null ||
              patient.weight != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (patient.bloodType != null)
                  _buildPatientMetric('Blood', patient.bloodType!, textTheme),
                if (patient.height != null)
                  _buildPatientMetric(
                    'Height',
                    '${patient.height}cm',
                    textTheme,
                  ),
                if (patient.weight != null)
                  _buildPatientMetric(
                    'Weight',
                    '${patient.weight}kg',
                    textTheme,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientMetric(String label, String value, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(Booking booking, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.reason != null) ...[
            Text(
              'Reason',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking.reason!,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (booking.notes != null) const SizedBox(height: 24),
          ],
          if (booking.notes != null) ...[
            Text(
              'Notes',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking.notes!,
              style: textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(
    List<BookingStatusUpdate> timeline,
    TextTheme textTheme,
  ) {
    if (timeline.isEmpty) return const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final update = timeline[index];
        final isLast = index == timeline.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        update.status,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, HH:mm').format(update.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    update.note,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStatusUpdateBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
    String targetStatus,
  ) {
    final noteController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;
    final isConfirming = targetStatus == 'CONFIRMED';
    final actionTitle = isConfirming ? 'Confirm Booking' : 'Complete Booking';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  actionTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isConfirming
                  ? 'Add a note to confirm this appointment.'
                  : 'Add final notes to complete this consultation.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: isConfirming
                    ? 'e.g. Booking confirmed, see you soon!'
                    : 'e.g. Patient has been consulted and prescribed meds.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(bookingRepositoryProvider)
                        .applyStatusAppointment(
                          encounterId: bookingId,
                          status: targetStatus,
                          note: noteController.text,
                        );

                    if (!context.mounted) return;
                    Navigator.pop(context); // Close bottom sheet

                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 48,
                        ),
                        content: Text(
                          'Appointment has been successfully ${targetStatus.toLowerCase()}.',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Refresh all relevant providers
                              ref.invalidate(bookingsProvider);
                              ref.invalidate(nearestAppointmentProvider);
                              ref.invalidate(doctorAppointmentsProvider);
                              ref.invalidate(doctorInsightsProvider);
                              ref.invalidate(bookingDetailsProvider(bookingId));

                              Navigator.pop(context); // Close dialog
                              context.go('/bookings'); // Navigate to list
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isConfirming ? 'Confirm Booking' : 'Complete Booking',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
