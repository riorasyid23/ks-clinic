import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisify/presentation/providers/auth_providers.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState is AuthAuthenticated
        ? authState.user.role
        : 'PATIENT';

    final List<_NavItem> items = role == 'DOCTOR'
        ? [
            const _NavItem(
              icon: Icons.home_filled,
              label: 'Home',
              route: '/home',
            ),
            const _NavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Appointment',
              route: '/bookings',
            ),
            const _NavItem(
              icon: Icons.access_time_rounded,
              label: 'Availability',
              route: '/availability',
            ),
            const _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              route: '/profile',
            ),
          ]
        : [
            const _NavItem(
              icon: Icons.home_filled,
              label: 'Home',
              route: '/home',
            ),
            const _NavItem(
              icon: Icons.search,
              label: 'Search',
              route: '/search',
            ),
            const _NavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Bookings',
              route: '/bookings',
            ),
            const _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              route: '/profile',
            ),
          ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildNavItem(
            context,
            item.icon,
            item.label,
            index,
            item.route,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    String route,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          if (route == '/profile') {
            context.push(route);
          } else {
            // Check if route exists in router, otherwise do nothing or show toast
            try {
              context.go(route);
            } catch (e) {
              // Route might not exist yet (like /availability)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon!')),
              );
            }
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
