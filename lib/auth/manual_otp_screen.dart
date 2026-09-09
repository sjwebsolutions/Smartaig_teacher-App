import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class ManualOtpScreen extends StatelessWidget {
  const ManualOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB0D7FE),
                  Color(0xFFE8D8FD),
                  Color(0xFFD3E1FD),
                  Color(0xFFD7E5FD),
                ],
              ),
            ),
          ),
          // Decorative Blobs outside SafeArea to reach the edges
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              height: 170,
              width: 170,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: Container(
              height: 200,
              width: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          "Manual OTP Login",
                          style: AppTextStyles.h1.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Contact Your School Administration To Get a Temporary OTP",
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.creamWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.creamWhiteborder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.brownattention,
                                size: 30,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Attention Required",
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.brownattention,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Use This Option Only If You Did Not Receive Your"
                                      " WhatsApp OTP. Contact School"
                                      " Admin With Registered Mobile Number To Get a Temporary OTP.",
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.attentiontheory,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Registered Mobile Number",
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: authController.mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: commonInputDecoration(
                            context: context,
                            icon: Icons.phone,
                            hintText: "Enter mobile number",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Enter Temporary OTP (Provided By School Admin)",
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: authController.manualOtpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: AppTextStyles.label.copyWith(letterSpacing: 12),
                          decoration: commonInputDecoration(
                            context: context,
                            icon: Icons.confirmation_num_outlined,
                            hintText: "_ _ _ _ _ _",
                          ).copyWith(
                            hintStyle: AppTextStyles.label.copyWith(
                              letterSpacing: 17,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  padding: const EdgeInsets.all(14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () => authController.loginWithManualOtp(),
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Login With Manual OTP",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                        ),
                                      ),
                              )),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock, size: 17),
                                Flexible(
                                  child: Text(
                                    "Manual OTP Is Valid For Limited Time And Single Use Only.",
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 13),
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

  InputDecoration commonInputDecoration({
    required BuildContext context,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon,size: 19,),

      hintText: hintText,
      hintStyle: AppTextStyles.body,

      filled: true,
      fillColor: AppColors.white,

      counterText: "",

      contentPadding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.03,
        ),
        borderSide: BorderSide(color: AppColors.grey),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.03,
        ),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
