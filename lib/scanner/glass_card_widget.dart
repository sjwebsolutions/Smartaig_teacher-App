import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:teacher_app_attendance/appColors_&_styles/app_Colors.dart';
import 'package:teacher_app_attendance/appColors_&_styles/text_styles.dart';

class GlassInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const GlassInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0x33000000),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.neutral, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
