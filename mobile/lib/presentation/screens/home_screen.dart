import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisify/presentation/providers/auth_providers.dart';
import 'package:medisify/presentation/widgets/app_bar_main.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/booking_providers.dart';
import '../../data/models/booking_model.dart';

import 'package:medisify/presentation/providers/doctor_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = user?.profile;
    final displayName = profile?.name ?? 'User';
    final role = user?.role ?? 'PATIENT';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppBarMain(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (role == 'DOCTOR') {
            return ref.refresh(doctorInsightsProvider);
          } else {
            return ref.refresh(nearestAppointmentProvider);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(textTheme, displayName),
                const SizedBox(height: 32),
                if (role == 'DOCTOR')
                  _buildDoctorDashboard(context, ref, textTheme)
                else
                  _buildPatientDashboard(context, ref, textTheme),
                const SizedBox(height: 48), // Padding for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildPatientDashboard(
    BuildContext context,
    WidgetRef ref,
    TextTheme textTheme,
  ) {
    final nearestAppointmentAsync = ref.watch(nearestAppointmentProvider);
    return Column(
      children: [
        _buildCTA(context),
        const SizedBox(height: 32),
        _buildNextAppointment(context, textTheme, nearestAppointmentAsync),
      ],
    );
  }

  Widget _buildDoctorDashboard(
    BuildContext context,
    WidgetRef ref,
    TextTheme textTheme,
  ) {
    final insightsAsync = ref.watch(doctorInsightsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Insights',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        insightsAsync.when(
          data: (data) => _buildStatusGrid(context, data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading insights: $err')),
        ),
        const SizedBox(height: 32),
        _buildDashboardActions(context, textTheme),
      ],
    );
  }

  Widget _buildStatusGrid(BuildContext context, Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          'Today',
          data['todayAppointmentTotal']?.toString() ?? '0',
          AppColors.primary,
          Icons.today,
        ),
        _buildStatusCard(
          'Pending',
          data['pendingAppointmentTotal']?.toString() ?? '0',
          Colors.orange,
          Icons.pending_actions,
        ),
        _buildStatusCard(
          'Confirmed',
          data['confirmedAppointmentTotal']?.toString() ?? '0',
          Colors.blue,
          Icons.check_circle_outline,
        ),
        _buildStatusCard(
          'Completed',
          data['completedAppointmentTotal']?.toString() ?? '0',
          Colors.green,
          Icons.done_all,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardActions(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActionTile(
          context,
          'My Appointments',
          'View and manage your schedule',
          Icons.calendar_month,
          AppColors.primary,
          () => context.go('/bookings'),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'Manage Availability',
          'Update your consultation hours',
          Icons.access_time_rounded,
          Colors.purple,
          () => context.go('/availability'),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(TextTheme textTheme, String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DASHBOARD',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hello, $displayName',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
            letterSpacing: -1.0,
            fontSize: 32, // Adjusted to match UI
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your health journey is looking stable today.',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => context.push('/search'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book New Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.onSecondaryFixed,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextAppointment(
    BuildContext context,
    TextTheme textTheme,
    AsyncValue<Booking?> asyncResult,
  ) {
    return asyncResult.when(
      loading: () => _buildShimmerAppointment(),
      error: (err, _) => _buildNoAppointmentCTA(context, textTheme),
      data: (booking) {
        if (booking == null) {
          return _buildNoAppointmentCTA(context, textTheme);
        }

        final dateFormat = DateFormat('MMM d, yyyy');
        return InkWell(
          onTap: () => context.push('/booking-details/${booking.id}'),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -16,
                  right: -16,
                  child: Icon(
                    Icons.event_available,
                    size: 100,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'NEXT APPOINTMENT',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: AppColors.outlineVariant,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    booking.currentStatus,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                booking.doctor?.name ?? 'Unknown Doctor',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.doctor?.specialty ?? 'Generalist',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildTag(
                          Icons.calendar_today,
                          dateFormat.format(booking.date),
                          textTheme,
                        ),
                        _buildTag(
                          Icons.schedule,
                          '${booking.startTime} - ${booking.endTime}',
                          textTheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoAppointmentCTA(BuildContext context, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming appointments',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your health journey on track. Schedule a consultation with our experienced doctors today.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text('Make Appointment Today'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAppointment() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTag(IconData icon, String text, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildServices(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Expanded slightly
            children: [
              _buildServiceIcon(Icons.science_outlined),
              _buildServiceIcon(Icons.medication_outlined),
              _buildServiceIcon(Icons.vaccines_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.onSurfaceVariant, size: 28),
    );
  }

  Widget _buildRecentDoctors(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.history, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                _buildAvatar(0),
                _buildAvatar(1),
                _buildAvatar(2),
                Positioned(
                  left: 3 * 36.0,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceContainerLow,
                        width: 4,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+2',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(int index) {
    return Positioned(
      left: index * 36.0,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceContainerLow, width: 4),
        ),
        child: const Icon(Icons.person, color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildVitality(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Daily Vitality',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildVitalityCard(
                'Heart Rate',
                '72',
                'bpm',
                Icons.favorite,
                AppColors.secondary,
                textTheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildVitalityCard(
                'Blood Pressure',
                '120/80',
                'mmHg',
                Icons.bloodtype,
                AppColors.primary,
                textTheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalityCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // added to fix layout errors on small screens
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
