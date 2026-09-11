import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/scanner/scanner_screen.dart';
import 'package:teacher_app_attendance/view/add_homework_screen_v2.dart';
import 'package:teacher_app_attendance/view/add_syllabus_screen.dart';
import 'package:teacher_app_attendance/view/app_blocked_screen.dart';
import 'package:teacher_app_attendance/view/attendance_screen.dart';
import 'package:teacher_app_attendance/view/class_list_screen.dart';
import 'package:teacher_app_attendance/view/homework_detail_screen.dart';
import 'package:teacher_app_attendance/view/main_screen.dart';
import 'package:teacher_app_attendance/view/marks_entry.dart';
import 'package:teacher_app_attendance/view/pdf_viewer_screen.dart';
import 'package:teacher_app_attendance/view/student_performance.dart';
import 'package:teacher_app_attendance/view/syllabus_screen.dart';
import 'package:teacher_app_attendance/view/syllabus_tracker.dart';
import 'package:teacher_app_attendance/view/upload_syllabus_screen.dart';
import 'package:teacher_app_attendance/view/upload_homework_screen.dart';
import 'package:teacher_app_attendance/view/view_marks_screen.dart';
import 'package:teacher_app_attendance/view/student_image_update_screen.dart';
import 'package:teacher_app_attendance/view/student_update_list_screen.dart';
import 'package:teacher_app_attendance/view/student_image_upload_screen.dart';
import 'package:teacher_app_attendance/view/date_sheet_screen.dart';
import 'package:teacher_app_attendance/view/date_sheet_detail_screen.dart';
import 'modules/attendance_module.dart';
import 'modules/auth_module.dart';
import 'modules/homework_module.dart';
import 'modules/main_module.dart';
import 'modules/marks_module.dart';
import 'modules/scanner_module.dart';
import 'modules/splash_module.dart';
import 'modules/syllabus_module.dart';
import 'modules/image_update_module.dart';
import 'services/device_service.dart';
import 'services/fcm_services.dart';
import 'auth/login_screen.dart';
import 'auth/splash_screen.dart';
import 'auth/verify_otp_screen.dart';
import 'view/screens/banner/banner_screen.dart';
import 'view/screens/banner/banner_detail_screen.dart';
import 'view/screens/banner/announcement_list_screen.dart';
import 'view/screens/banner/add_announcement_screen.dart';
import 'view/screens/get_pass/get_pass_screen.dart';
import 'modules/banner_module.dart';
import 'modules/announcement_module.dart';
import 'modules/date_sheet_module.dart';
import 'view/time_table_screen.dart';
import 'modules/time_table_module.dart';
import 'modules/gate_pass_module.dart';
import 'modules/invigilator_module.dart';
import 'view/invigilator_duties_screen.dart';
import 'view/invigilator_duty_detail_screen.dart';
import 'view/admit_card_scanner_screen.dart';
import 'view/admit_card_detail_screen.dart';
import 'modules/admit_card_scanner_module.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  
  // If the message contains a notification object, the OS will handle it on Android.
  // If it is a data-only message, we can show it manually:
  if (message.notification == null && message.data.isNotEmpty) {
    await FcmService.showLocalNotification(
      title: message.data['title'] ?? "New Notification",
      body: message.data['body'] ?? "You have received a new update.",
    );
  }

  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  try {
    await Firebase.initializeApp();
    
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize FCM and other services without awaiting them to avoid blocking UI
    FcmService.initialize();
    _initializeServices();
  } catch (e) {
    debugPrint("App Initialization Error: $e");
  }

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    final deviceInfo = await DeviceService.getDeviceInfo();
    debugPrint("DEVICE UUID => ${deviceInfo['device_uuid']}");
    
    final token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 5));
    debugPrint("FCM token : $token");
    
    // Also register token to server
    await FcmService.registerFcmToken();
  } catch (e) {
    debugPrint("Service Initialization Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashScreen(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/verifyOtp',
          page: () => OtpVerify(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const MainScreen(),
          binding: MainBinding(),
        ),
        GetPage(
          name: '/scanner',
          page: () => ScannerScreen(),
          binding: ScannerBinding(),
        ),
        GetPage(
          name: '/attendance',
          page: () => AttendanceScreen(),
          binding: AttendanceBinding(),
        ),
        GetPage(
          name: '/classList',
          page: () => const ClassListScreen(),
        ),
        GetPage(
          name: '/uploadHomework',
          page: () => const UploadHomeworkScreen(),
          binding: HomeworkBinding(),
        ),
        GetPage(
          name: '/addHomework',
          page: () => const NewAddHomeworkScreen(),
          binding: HomeworkBinding(),
        ),
        GetPage(
          name: '/homeworkDetail',
          page: () => const HomeworkDetailScreen(),
          binding: HomeworkBinding(),
        ),
        GetPage(
          name: '/marksEntry',
          page: () => const MarksEntryScreen(),
          binding: MarksBinding(),
        ),
        GetPage(
          name: '/syllabus',
          page: () => const SyllabusScreen(),
          binding: SyllabusBinding(),
        ),
        GetPage(
          name: '/uploadSyllabus',
          page: () => const UploadSyllabusScreen(),
          binding: SyllabusBinding(),
        ),
        GetPage(
          name: '/syllabusTracker',
          page: () => const SyllabusTrackerScreen(),
          binding: SyllabusBinding(),
        ),
        GetPage(
          name: '/addSyllabus',
          page: () => const AddSyllabusScreen(),
          binding: SyllabusBinding(),
        ),
        GetPage(
          name: '/studentPerformance',
          page: () => const StudentPerformanceScreen(),
        ),
        GetPage(
          name: '/viewMarks',
          page: () => const ViewMarksScreen(),
          binding: MarksBinding(),
        ),
        GetPage(
          name: '/banners',
          page: () => const BannerScreen(),
          binding: BannerBinding(),
        ),
        GetPage(
          name: '/announcements',
          page: () => const AnnouncementListScreen(),
          binding: AnnouncementBinding(),
        ),
        GetPage(
          name: '/bannerDetail',
          page: () => const BannerDetailScreen(),
        ),
        GetPage(
          name: '/getPass',
          page: () => const GetPassScreen(),
          binding: GatePassBinding(),
        ),
        GetPage(
          name: '/addAnnouncement',
          page: () => const AddAnnouncementScreen(),
          binding: AnnouncementBinding(),
        ),
        GetPage(
          name: '/studentImageUpdate',
          page: () => const StudentImageUpdateScreen(),
          binding: ImageUpdateBinding(),
        ),
        GetPage(
          name: '/studentUpdateList',
          page: () => const StudentUpdateListScreen(),
          binding: ImageUpdateBinding(),
        ),
        GetPage(
          name: '/studentImageUpload',
          page: () => const StudentImageUploadScreen(),
          binding: ImageUpdateBinding(),
        ),
        GetPage(
          name: '/pdfViewer',
          page: () => const PdfViewerScreen(),
        ),
        GetPage(
          name: '/blocked',
          page: () => AppBlockedScreen(message: Get.arguments ?? "Access Blocked"),
        ),
        GetPage(
          name: '/dateSheet',
          page: () => const DateSheetScreen(),
          binding: DateSheetBinding(),
        ),
        GetPage(
          name: '/dateSheetDetail',
          page: () => const DateSheetDetailScreen(),
        ),
        GetPage(
          name: '/timeTable',
          page: () => const TimeTableScreen(),
          binding: TimeTableBinding(),
        ),
        GetPage(
          name: '/invigilatorDuties',
          page: () => const InvigilatorDutiesScreen(),
          binding: InvigilatorBinding(),
        ),
        GetPage(
          name: '/invigilatorDutyDetail',
          page: () => const InvigilatorDutyDetailScreen(),
          binding: InvigilatorBinding(),
        ),
        GetPage(
          name: '/admitCardScanner',
          page: () => const AdmitCardScannerScreen(),
          binding: AdmitCardScannerBinding(),
        ),
        GetPage(
          name: '/admitCardDetail',
          page: () => const AdmitCardDetailScreen(),
        ),
      ],
    );
  }
}
