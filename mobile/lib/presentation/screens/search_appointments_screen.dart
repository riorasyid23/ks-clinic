import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/clinical_card.dart';
import '../widgets/custom_text_field.dart';
import '../providers/appointment_providers.dart';

class SearchAppointmentsScreen extends ConsumerWidget {
  const SearchAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final recommendedDocs = ref.watch(recommendedDoctorsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Find Doctor'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const CustomTextField(
              label: 'Search by specialty or doctor name',
            ),
            const SizedBox(height: 32),
            Text('Specialties', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSpecialtyCard(context, Icons.monitor_heart, 'Cardiology'),
                  const SizedBox(width: 16),
                  _buildSpecialtyCard(context, Icons.psychology, 'Neurology'),
                  const SizedBox(width: 16),
                  _buildSpecialtyCard(context, Icons.child_care, 'Pediatrics'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Recommended Doctors', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final doc = recommendedDocs[index];
                return ClinicalCard(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.name, style: textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(doc.specialty, style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text('${doc.rating} (${doc.reviewCount} reviews)', style: textTheme.labelMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(BuildContext context, IconData icon, String title) {
    return ClinicalCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
