import 'package:get/get.dart';
import 'package:teacher_app_attendance/api_service/dashboard_service.dart';
import 'package:teacher_app_attendance/models/dashboard_model.dart';
import '../api_service/attendance_scanner_service.dart';

class DashboardController extends GetxController{

  final AttendanceServices _attendanceServices = AttendanceServices();
  final DashboardServices _dashboardServices = DashboardServices();
  
  final isLoading = false.obs;
  final dashboard = Rxn<DashboardTeacherModel>();

  var lastMarkedTime = Rxn<DateTime>();
  var clockInTime = Rxn<DateTime>();
  var clockOutTime = Rxn<DateTime>();

  var attendanceStatus = "Clock In".obs;
  var isMarked = false.obs;

  @override
  void onInit(){
    print("DashboardController hash: ${hashCode}");
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async{
    try{
      isLoading.value = true;
      final result = await _dashboardServices.getDashboard();
      dashboard.value = result;

      if (result.data?.todayAttendance != null) {
        isMarked.value = result.data?.todayAttendance?.isMarked ?? false;
        if (result.data?.todayAttendance?.clockIn != null) {
          clockInTime.value = DateTime.tryParse(result.data!.todayAttendance!.clockIn!);
          lastMarkedTime.value = clockInTime.value;
        }
        if (result.data?.todayAttendance?.clockOut != null) {
          clockOutTime.value = DateTime.tryParse(result.data!.todayAttendance!.clockOut!);
        }
        attendanceStatus.value = isMarked.value ? "Clock Out" : "Clock In";
      } else {
        isMarked.value = false;
        clockInTime.value = null;
        clockOutTime.value = null;
        attendanceStatus.value = "Clock In";
      }
    } catch (e){
      Get.snackbar("Error", e.toString());
    }finally{
      isLoading.value = false;
    }
  }


  void updateAttendanceStatus(){
    isMarked.value = true;
    final now = DateTime.now();
    lastMarkedTime.value = now;
    
    if(attendanceStatus.value == "Clock In"){
      clockInTime.value = now;
      attendanceStatus.value = "Clock Out";
    }else{
      clockOutTime.value = now;
      attendanceStatus.value = "Clock In";
    }
  }

  void markAttendance() {
    updateAttendanceStatus();
  }

  Future<void> resetAttendanceForTesting() async {
    try {
      isLoading.value = true;

      final success = await _attendanceServices.deleteTodayAttendance();

      if (success) {
        isMarked.value = false;
        lastMarkedTime.value = null;
        attendanceStatus.value = "Clock In";

        Get.snackbar(
          "Success",
          "Attendance deleted successfully",
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
