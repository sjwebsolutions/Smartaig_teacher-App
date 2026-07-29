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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.white.withOpacity(0.18)),
            gradient: LinearGradient(
              colors: [
                AppColors.white.withOpacity(0.18),
                AppColors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,color: AppColors.neutral,size: 18,),
              SizedBox(height: 6,),
              Text(title,style: AppTextStyles.body.copyWith(color: AppColors.white,fontWeight: FontWeight.w700),),
              SizedBox(height: 4,),
              Text(subtitle,style: AppTextStyles.body.copyWith(color: AppColors.white.withOpacity(0.8),fontSize: 12),)
            ],
          ),
        ),
      ),
    );
  }
}
