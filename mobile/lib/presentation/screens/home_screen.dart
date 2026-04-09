import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/clinical_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.7),
          ),
        ),
        title: Text(
          'Good Morning, Alex',
          style: textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard overview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upcoming Appointment', style: textTheme.labelMedium),
                          const SizedBox(height: 8),
                          Text('Dr. Sarah Sterling', style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('Cardiology • Today, 2:30 PM', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Quick Actions', style: textTheme.headlineLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: ClinicalCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search, color: AppColors.primary, size: 32),
                          const SizedBox(height: 12),
                          Text('Find Doctor', style: textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClinicalCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary, size: 32),
                          const SizedBox(height: 12),
                          Text('My Bookings', style: textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // More content can be built mimicking \"No-Line\" rules
            ],
          ),
        ),
      ),
      // Glass & Gradient Rule Example
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.7),
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withOpacity(0.15),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', true),
            _buildNavItem(Icons.calendar_month_outlined, 'Bookings', false),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
