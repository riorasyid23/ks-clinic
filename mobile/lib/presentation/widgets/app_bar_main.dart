import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppBarMain extends StatelessWidget implements PreferredSizeWidget {
  const AppBarMain({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      title: Text(
        'Medisify',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.primaryContainer,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.medical_services,
          color: AppColors.primaryContainer,
        ),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryFixed, width: 2),
              color: AppColors.surfaceContainerHigh,
            ),
            // child: const Icon(Icons.person, color: AppColors.primaryContainer),
            child: InkWell(
              onTap: () => context.push('/profile'),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
