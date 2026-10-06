import 'package:get/get.dart';
import '../api_service/student_attendance_service.dart';
import '../api_service/student_leave_service.dart';
import '../models/class_list_model.dart';
import '../models/student_leave_model.dart';

class StudentLeaveController extends GetxController {
  final StudentLeaveService _service = StudentLeaveService();
  final StudentAttendanceService _attendanceService = StudentAttendanceService();

  var isLoading = false.obs;
  var isClassesLoading = false.obs;
  var errorMessage = "".obs;

  var classes = <ClassData>[].obs;
  var selectedClass = Rxn<ClassData>();

  var selectedStatus = "all".obs; // 'all', 'pending', 'approved', 'rejected'
  var selectedDate = "".obs; // 'YYYY-MM-DD'

  var studentLeavesResponse = Rxn<StudentLeaveModel>();
  var leavesList = <StudentLeaveData>[].obs;
  var canApprove = false.obs;

  @override
  void onInit() {
    print("StudentLeaveController Initialized");
    super.onInit();
    fetchInchargeClasses();
  }

  Future<void> fetchInchargeClasses() async {
    try {
      isClassesLoading.value = true;
      errorMessage.value = "";
      final classResponse = await _attendanceService.getInchargeClasses();
      if (classResponse.success == true && classResponse.data != null && classResponse.data!.isNotEmpty) {
        classes.assignAll(classResponse.data!);
        selectedClass.value = classes.first;
        await fetchStudentLeaves();
      } else {
        errorMessage.value = "No incharge classes found";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isClassesLoading.value = false;
    }
  }

  Future<void> fetchStudentLeaves() async {
    if (selectedClass.value == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final cls = selectedClass.value!;
      final response = await _service.getStudentLeaves(
        classId: cls.classId,
        sectionId: cls.sectionId,
        streamId: cls.streamId,
        status: selectedStatus.value,
        date: selectedDate.value,
      );

      studentLeavesResponse.value = response;
      canApprove.value = response.canApprove ?? false;
      leavesList.assignAll(response.data ?? []);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void changeClass(ClassData cls) {
    selectedClass.value = cls;
    fetchStudentLeaves();
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
    fetchStudentLeaves();
  }

  void setDateFilter(String dateStr) {
    selectedDate.value = dateStr;
    fetchStudentLeaves();
  }

  void clearDateFilter() {
    selectedDate.value = "";
    fetchStudentLeaves();
  }

  Future<bool> approveLeave(int leaveId, String? remarks) async {
    try {
      isLoading.value = true;
      final success = await _service.approveLeave(leaveId: leaveId, remarks: remarks);
      if (success) {
        await fetchStudentLeaves();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rejectLeave(int leaveId, String reason) async {
    try {
      isLoading.value = true;
      final success = await _service.rejectLeave(leaveId: leaveId, rejectionReason: reason);
      if (success) {
        await fetchStudentLeaves();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
