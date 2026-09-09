import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';

import 'package:get/get.dart';

import 'manual_otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    final size = MediaQuery.of(context).size;
    final fieldHeight = Get.height * 0.065;
    final countryCodeWidth = Get.width * 0.16;

    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Stack(
            children: [
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
                top: 100,
                right: -80,
                child: Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
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
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: size.height * 0.08),

                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/splash_logo.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Text(
                        "Teacher Login",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(color: AppColors.primary,fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Enter your Registered Mobile Number",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withOpacity(0.90),
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(23),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(color: AppColors.grey, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile Number",
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.black.withOpacity(0.90),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 20),
                            //phone input row
                            Row(
                              children: [
                                Container(
                                  width: countryCodeWidth,
                                  height: fieldHeight,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: Text(
                                    "🇮🇳+91",
                                    style: AppTextStyles.h2.copyWith(
                                        color: AppColors.black.withOpacity(0.7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: fieldHeight,
                                    child: TextFormField(
                                      autofocus: false,
                                      focusNode: authController.mobileFocusNode,
                                      controller: authController.mobileController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      onTap: () {
                                        authController.mobileFocusNode.requestFocus();
                                      },
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "Enter Mobile number",
                                        hintStyle: AppTextStyles.body.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400
                                        ),

                                        filled: true,
                                        fillColor: Colors.white38,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authController.isLoading.value ? null : () {
                                  authController.sendOtp();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  disabledBackgroundColor: AppColors.green.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  "Send OTP",
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                            )),
                            Padding(
                              padding: const EdgeInsets.all(13),
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => const ManualOtpScreen());
                                  },
                                  child: Text(
                                    "Didn't receive OTP? Use Manual OTP",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary.withOpacity(0.90),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          children: [
                            /// First Box
                            Expanded(
                              child: Container(
                                height: 70,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.grey),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shield_outlined,color: AppColors.primary,),
                                    Expanded(
                                      child: Text(
                                        "Secure AES-256 encrypted access",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// Second Box
                            Expanded(
                              child: Container(
                                height: 70,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.grey),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined,color: AppColors.primary,),
                                    Expanded(
                                      child: Text(
                                        "Institutional verified gateway.",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Text(
                              "Only registered staff can login in ",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.blacklight,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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
    );
  }
}
