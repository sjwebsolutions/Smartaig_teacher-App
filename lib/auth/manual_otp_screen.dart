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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primary(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_outlined, size: 30),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 10),
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
                            backgroundColor: AppColors.primary,
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
                                    fontWeight: FontWeight.w400,
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
