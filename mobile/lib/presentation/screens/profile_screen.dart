import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);

    // Extract user data from auth state
    final user = authState is AuthAuthenticated ? authState.user : null;
    final profile = user?.profile;

    final displayName = profile?.name ?? 'Guest User';
    final displayEmail = user?.email ?? '--';
    final displayPhone = profile?.phoneNumber ?? '--';
    final displayRole = user?.role ?? 'PATIENT';
    final displayHeight = profile?.height != null
        ? '${profile!.height} cm'
        : '-- cm';
    final displayWeight = profile?.weight != null
        ? '${profile!.weight} kg'
        : '-- kg';
    final displayBlood = profile?.bloodType ?? '-- Type';
    final displayDob = _formatDob(profile?.dateOfBirth);

    final isProfileComplete =
        profile?.height != null &&
        profile?.weight != null &&
        profile?.bloodType != null &&
        profile?.dateOfBirth != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  _buildHero(context, textTheme, displayName, displayRole),
                  const SizedBox(height: 32),
                  _buildContactInfo(
                    Icons.mail_outline,
                    'Email Address',
                    displayEmail,
                    textTheme,
                  ),
                  _buildContactInfo(
                    Icons.phone_outlined,
                    'Phone Number',
                    displayPhone,
                    textTheme,
                  ),
                  const SizedBox(height: 32),
                  _buildMedicalStats(
                    textTheme,
                    height: displayHeight,
                    weight: displayWeight,
                    blood: displayBlood,
                    dob: displayDob,
                    isComplete: isProfileComplete,
                  ),
                  const SizedBox(height: 32),
                  _buildAccountSettings(context, textTheme),
                  const SizedBox(height: 48),
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  String _formatDob(String? dateOfBirth) {
    if (dateOfBirth == null) return '-- / -- / --';
    try {
      final date = DateTime.parse(dateOfBirth);
      return '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
    } catch (_) {
      return '-- / -- / --';
    }
  }

  Widget _buildHero(
    BuildContext context,
    TextTheme textTheme,
    String name,
    String role,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 4),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(
    IconData icon,
    String label,
    String value,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.ambientShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalStats(
    TextTheme textTheme, {
    required String height,
    required String weight,
    required String blood,
    required String dob,
    required bool isComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical Statistics',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.secondaryFixed
                    : AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isComplete ? 'COMPLETE' : 'INCOMPLETE',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isComplete ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _buildStatCard(
              Icons.straighten,
              'Height',
              height,
              AppColors.primary,
              textTheme,
            ),
            _buildStatCard(
              Icons.monitor_weight_outlined,
              'Weight',
              weight,
              AppColors.primary,
              textTheme,
            ),
            _buildStatCard(
              Icons.bloodtype,
              'Blood',
              blood,
              AppColors.error,
              textTheme,
            ),
            _buildStatCard(
              Icons.calendar_today,
              'DOB',
              dob,
              AppColors.primary,
              textTheme,
            ),
          ],
        ),
        if (!isComplete) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Complete Medical Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryFixed,
                foregroundColor: AppColors.onSecondaryFixed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color iconColor,
    TextTheme textTheme,
  ) {
    final hasData = !value.contains('--');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(
                title,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasData
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.ambientShadow,
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.person_outline,
                'Edit Profile',
                textTheme,
                onTap: () => context.push('/edit-profile'),
              ),
              const Divider(
                height: 1,
                indent: 64,
                color: AppColors.outlineVariant,
              ),
              _buildSettingItem(
                Icons.shield_outlined,
                'Insurance Details',
                textTheme,
              ),
              const Divider(
                height: 1,
                indent: 64,
                color: AppColors.outlineVariant,
              ),
              _buildSettingItem(
                Icons.notifications_outlined,
                'Notification Settings',
                textTheme,
              ),
              const Divider(
                height: 1,
                indent: 64,
                color: AppColors.outlineVariant,
              ),
              _buildSettingItem(
                Icons.help_outline,
                'Help & Support',
                textTheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    TextTheme textTheme, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.outlineVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              foregroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'KS CLINIC • Medisify',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.outlineVariant,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
