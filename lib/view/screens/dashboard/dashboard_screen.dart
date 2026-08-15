//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:teacher_app_attendance/controller/auth_controller.dart';
//
// import '../../../controller/banner_controller.dart';
// import '../../../controller/dashboard_controller.dart';
// import '../../../themes/appColors_&_styles/app_Colors.dart';
// import '../../../themes/appColors_&_styles/text_styles.dart';
// import '../../../themes/app_bar/app_top_bar.dart';
// import 'package:get/get.dart';
//
// import '../../academic_modules_screens.dart';
// import '../banner/banner_widget.dart';
//
// class TeacherDashboardScreen extends StatelessWidget {
//   TeacherDashboardScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final dashboardController = Get.find<DashboardController>();
//     final authController = Get.find<AuthController>();
//
//     final dash = dashboardController;
//     const EdgeInsets kCardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
//     const EdgeInsets kCardPadding = EdgeInsets.all(14);
//     return Container(
//       decoration: BoxDecoration(
//         gradient: AppGradients.primary(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppTopBar(
//           backgroundColor: Colors.transparent,
//
//           showBack: false,
//           showDivider: true,
//           customTitle: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Teacher Dashboard", style: AppTextStyles.appbarh4),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           actions: [
//             IconButton(
//               onPressed: () {
//                 authController.logout();
//               },
//               icon: const Icon(Icons.logout, size: 19, color: AppColors.red),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: RefreshIndicator(
//             onRefresh: () async {
//               await dashboardController.fetchDashboard();
//               if (Get.isRegistered<BannerController>()) {
//                 await Get.find<BannerController>().fetchBanners();
//               }
//             },
//             color: AppColors.primary,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               child: Container(
//                 width: double.infinity,
//                 color: Colors.transparent,
//
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 1,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//
//                       children: [
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Padding(
//                             padding: EdgeInsets.only(
//                               left: Get.width * 0.04,
//                               right: Get.width * 0.04,
//                               top: Get.height * 0.007,
//                               bottom: Get.height * 0.004,
//                             ),
//                             child: Text(
//                               "Welcome",
//                               style: AppTextStyles.body.copyWith(
//                                 color: AppColors.black.withValues(alpha: 0.60),
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                               ),
//
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     margin: kCardMargin,
//                     child: Card(
//                       color: AppColors.white,
//                       elevation: 1,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//
//                       child: Padding(
//                         padding: kCardPadding,
//                         child: Obx(() {
//                           final data = dash.dashboard.value?.data;
//                           final teacher = data?.teacher;
//
//                           return Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 28,
//                                 backgroundColor: AppColors.grey.withValues(alpha: 0.2),
//                                 backgroundImage: (teacher?.image != null && teacher!.image!.isNotEmpty)
//                                     ? NetworkImage(teacher.image!)
//                                     : null,
//                                 child: (teacher?.image == null || teacher!.image!.isEmpty)
//                                     ? const Icon(Icons.person, color: AppColors.primary, size: 30)
//                                     : null,
//                               ),
//
//                               const SizedBox(width: 12),
//
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       teacher?.name ?? "No name",
//                                       style: AppTextStyles.body.copyWith(
//                                         color: AppColors.black.withValues(alpha: 0.8),
//                                         fontSize: 18,
//                                       ),
//                                     ),
//
//                                     Text(
//                                       teacher?.staffType ?? "No role",
//                                       style: AppTextStyles.body.copyWith(
//                                         color: AppColors.black.withValues(alpha: 0.8),
//                                         fontSize: 14,
//                                       ),
//                                     ),
//
//                                     Text(
//                                       "Emp ID: ${teacher?.id ?? '-'}",
//                                       style: AppTextStyles.body.copyWith(
//                                         color: AppColors.black.withValues(alpha: 0.4),
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                   const BannerWidget(),
//                   Container(
//                     margin: kCardMargin,
//                     width: double.infinity,
//                     child: Card(
//                       color: AppColors.white,
//                       elevation: 1,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: kCardPadding,
//                         child: Column(
//                           children: [
//
//                             /// Header
//                             Obx(() {
//                               final isLoading = dashboardController.isLoading.value;
//                               final attendance = dashboardController.dashboard.value?.data?.todayAttendance;
//                               final isPresent = attendance?.status == "present" || dashboardController.isMarked.value;
//
//                               String statusText = "Checking...";
//                               Color statusColor = AppColors.grey;
//                               Color bgColor = AppColors.grey.withValues(alpha: 0.12);
//
//                               if (!isLoading) {
//                                 statusText = attendance?.statusLabel ?? (isPresent ? "Present" : "Absent");
//                                 statusColor = isPresent ? AppColors.green : AppColors.red;
//                                 bgColor = (isPresent ? AppColors.green : AppColors.red).withValues(alpha: 0.12);
//                               }
//
//                               return Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Daily Attendance",
//                                     style: AppTextStyles.body.copyWith(
//                                       color: AppColors.black,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: bgColor,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       statusText,
//                                       style: AppTextStyles.body.copyWith(
//                                         color: statusColor,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }),
//
//                             const SizedBox(height: 24),
//
//                             /// Attendance Circle
//                             Obx(() {
//                               final isMarked = dashboardController.isMarked.value;
//
//                               return GestureDetector(
//                                 onTap: () {
//                                   Get.toNamed('/scanner', preventDuplicates: true);
//                                 },
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//
//                                     /// CIRCLE BUTTON
//                                     AnimatedContainer(
//                                       duration: const Duration(milliseconds: 400),
//                                       width: 100, // smaller size
//                                       height: 100,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: AppColors.white,
//                                         border: Border.all(
//                                           color: AppColors.creamWhite.withValues(alpha: 0.3), // grey outline
//                                           width: 1.5,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withValues(alpha: 0.06),
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 3),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Center(
//                                         child: Icon(
//                                           Icons.qr_code_2,
//                                           color: AppColors.primary,
//                                           size: 30,
//                                         ),
//                                       ),
//                                     ),
//
//                                     const SizedBox(height: 12),
//
//                                     /// BOTTOM STATUS PILL
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: isMarked
//                                             ? Colors.red.withValues(alpha: 0.1)
//                                             : AppColors.primary.withValues(alpha: 0.1),
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Text(
//                                         isMarked ? "Clock-Out" : "Clock-In",
//                                         style: TextStyle(
//                                           color: isMarked ? AppColors.red : AppColors.primary,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//
//                             const SizedBox(height: 25),
//
//                             /// Bottom Section (Clock In & Out)
//                             Obx(() {
//                               final clockIn = dashboardController.clockInTime.value;
//                               final clockOut = dashboardController.clockOutTime.value;
//
//                               return Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       _timeInfo("Last Clock-In:", clockIn),
//                                       _timeInfo("Last Clock-Out:", clockOut),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Text(
//                                       dashboardController.isLoading.value
//                                           ? "Checking..."
//                                           : (dashboardController.isMarked.value ? "Attendance Marked" : "Not Marked"),
//                                       style: AppTextStyles.body.copyWith(
//                                         color: AppColors.black.withValues(alpha: 0.5),
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 19,
//                           vertical: 1,
//                         ),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Academic Modules",
//                                 style: AppTextStyles.body.copyWith(
//                                   color: AppColors.black.withValues(alpha: 0.60),
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const AcademicModuleGrid(),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 19,
//                       vertical: 1,
//                     ),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Professional Details",
//                         style: AppTextStyles.body.copyWith(
//                           color: AppColors.black.withValues(alpha: 0.60),
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10,),
//                   Container(
//                     margin: kCardMargin,
//                     child: Card(
//                       elevation: 1,
//                       color: AppColors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Obx(() {
//                           final teacher = dash.dashboard.value?.data?.teacher;
//
//                           return Column(
//                             children: [
//                               _tile(Icons.email, "Email", teacher?.email ?? "Not Available"),
//                               _divider(),
//
//                               _tile(Icons.phone, "Phone", teacher?.phone ?? "Not Available"),
//                               _divider(),
//
//                               _tile(Icons.badge, "Staff Type", teacher?.staffType ?? "Not Available"),
//                               _divider(),
//
//                               _tile(Icons.school, "School ID", teacher?.schoolId ?? "Not Available"),
//                               _divider(),
//
//                               _tile(Icons.person_outline, "Teacher ID", teacher?.teacherUniqueId ?? "Not Available"),
//                             ],
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//     );
//   }
//
//   Widget _timeInfo(String label, DateTime? time) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.body.copyWith(
//             color: AppColors.black.withValues(alpha: 0.3),
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           time != null ? DateFormat('hh:mm a').format(time) : "--:--",
//           style: AppTextStyles.body.copyWith(
//             color: AppColors.black,
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _tile(IconData icon, String title, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: Get.width * 0.05,
//         vertical: 6,
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(Get.width * 0.025),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(Get.width * 0.025),
//             ),
//             child: Icon(icon, color: AppColors.primary, size: Get.width * 0.05),
//           ),
//
//           SizedBox(width: Get.width * 0.03),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.black.withValues(alpha: 0.8),
//                     fontSize: Get.width * 0.03,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.black.withValues(alpha: 0.9),
//                     fontSize: Get.width * 0.04,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _divider() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       height: 2,
//       color: AppColors.grey.withValues(alpha: 0.4),
//     );
//   }
// }
