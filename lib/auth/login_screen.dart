import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';

import 'package:get/get.dart';

import 'manual_otp_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    //final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    //final FocusNode _focusNode = FocusNode();
    final fieldHeight = Get.height * 0.065;
    final countryCodeWidth = Get.width * 0.16;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppGradients.primary()),
          child: SafeArea(
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
                  margin: EdgeInsets.all(23),
                  padding: EdgeInsets.all(20),
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
                                autofocus: true,
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
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
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
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                           authController.sendOtp();

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 8.0),
                              //   child: Icon(
                              //     Icons.message,
                              //     color: AppColors.white,
                              //     size: 30,
                              //   ),
                              // ),
                              // SizedBox(width: 2),


                              Obx(() {
                                return authController.isLoading.value
                                    ? CircularProgressIndicator(
                                        color: AppColors.white,
                                      )
                                    : Text(
                                        "Send OTP",
                                        style: AppTextStyles.h2.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23
                                        ),
                                      );
                              }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(13),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Get.to(() => ManualOtpScreen());
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
                               Icon(Icons.shield_outlined,color: AppColors.primary,),
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
                             Icon(Icons.verified_user_outlined,color: AppColors.primary,),
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
      ),
      ));
  }
}
