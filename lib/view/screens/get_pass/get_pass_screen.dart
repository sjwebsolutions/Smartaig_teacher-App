import 'package:flutter/material.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';

class GetPassScreen extends StatelessWidget {
  const GetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: const AppTopBar(
        title: "Get Pass",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewPassButton(),
            const SizedBox(height: 24),
            Text(
              "Active Pass",
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildActivePassCard(),
            const SizedBox(height: 24),
            Text(
              "Recent Passes",
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentPassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPassButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3D4E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Request New Gate Pass",
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePassCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PASS TYPE",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Short Leave",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "APPROVED",
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPassDetail("Date", "28 Jul, 2024"),
              _buildPassDetail("Time", "02:30 PM"),
              _buildPassDetail("Duration", "2 Hours"),
            ],
          ),
          const SizedBox(height: 25),
          // Fake QR Code Area
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  "GP-2024-8842",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentPassesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final passTypes = ["Gate Pass", "Short Leave", "Official Duty"];
        final dates = ["26 Jul", "24 Jul", "20 Jul"];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.history, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passTypes[index],
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Reason: Personal Work",
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dates[index],
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Expired",
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
