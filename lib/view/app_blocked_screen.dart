import 'package:flutter/material.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class AppBlockedScreen extends StatelessWidget {
  final String message;
  final bool isEmbedded;

  const AppBlockedScreen({
    super.key,
    required this.message,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(gradient: AppGradients.primary()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.block,
            color: AppColors.red,
            size: 120,
          ),
          const SizedBox(height: 30),
          Text(
            "Access Blocked",
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.black.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Please contact your school administration for further assistance.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (isEmbedded) {
      return content;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: content,
      ),
    );
  }
}
