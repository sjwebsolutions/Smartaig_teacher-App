class ApiUrls {
  static const String baseUrl = "https://smartaig.com/api/v1/teacher";
  static const String otpRequest = "$baseUrl/auth/otp/request";
  static const String verifyOtp = "$baseUrl/auth/otp/verify";
  static const String dashboard = "$baseUrl/dashboard";
  static const String logout = "$baseUrl/auth/logout";
  static const String attendance = "$baseUrl/attendance/clock";
  static const String deleteattendance = "$baseUrl/attendance/today";
  static const String fcmToken = "$baseUrl/devices/fcm-token";
  static const String homework = "$baseUrl/homework";
  static const String homeworkFormData = "$baseUrl/homework/form-data";
  static const String inchargeClasses = "$baseUrl/student-attendance/incharge-classes";
  static const String studentList = "$baseUrl/student-attendance/students";
  static const String storeAttendance = "$baseUrl/student-attendance/store";
  static const String marksEntries = "$baseUrl/marks-entries";
  static String marksEntryClasses(int id) => "$marksEntries/$id/classes";
  static String marksEntryStudents(int id) => "$marksEntries/$id/students";
  static const String saveMarks = "$baseUrl/marks-entries/save";
  static const String submitMarks = "$baseUrl/marks-entries/submit";
  static const String banners = "$baseUrl/banners";
  static const String announcements = "$baseUrl/announcements";
  static const String teacherSyllabus = "$baseUrl/syllabus";
  static const String studentImageUpdateClasses = "$baseUrl/student-image-update-requests/classes";
  static const String studentImageUpdateStudents = "$baseUrl/student-image-update-requests/students";
  static const String studentImageUpdateStore = "$baseUrl/student-image-update-requests/store";
  static const String dateSheets = "$baseUrl/datesheets";
  static String dateSheetDetails(int id) => "$dateSheets/$id";

  static String syllabus(int studentId) => "https://smartaig.com/api/v1/students/$studentId/syllabus";
}
