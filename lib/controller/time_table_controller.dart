import 'package:get/get.dart';
import '../api_service/time_table_service.dart';
import '../models/time_table_model.dart';

class TimeTableController extends GetxController {
  final TimeTableService _service = TimeTableService();

  var isLoading = false.obs;
  var hasFetched = false.obs;
  var errorMessage = "".obs;
  var timeTableModel = Rxn<TimeTableModel>();
  var selectedDay = "".obs;
  var timeTables = <TimeTablePeriod>[].obs; // Expose list for badge count in academic_modules_screens.dart

  @override
  void onInit() {
    print("TimeTableController Initialized");
    super.onInit();
    fetchTimeTable();
  }

  Future<void> fetchTimeTable({String? date, Map<String, dynamic>? headers}) async {
    try {
      print("Controller: fetchTimeTable() called");
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _service.getTimeTable(date: date, headers: headers);
      print("Controller: success = ${response.success}");
      if (response.success == true && response.data != null) {
        timeTableModel.value = response;
        // Set default selected day from API response
        selectedDay.value = response.data?.selectedDay ?? _getCurrentDayName();
        // Set today's schedule for badge count
        timeTables.assignAll(response.data?.dailySchedule ?? []);
      } else {
        print("Controller: response.success is false or data is null");
      }
      hasFetched.value = true;
    } catch (e) {
      print("Controller: catch error = $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("Controller: fetchTimeTable() finished. isLoading = ${isLoading.value}");
    }
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    // weekday is 1-7 (Monday-Sunday)
    if (now.weekday >= 1 && now.weekday <= 7) {
      return weekdays[now.weekday - 1];
    }
    return "Monday";
  }

  // Retrieve schedule list for the selected day
  List<TimeTablePeriod> getPeriodsForSelectedDay() {
    final data = timeTableModel.value?.data;
    if (data == null) return [];
    
    // If selectedDay matches the day from API response (selectedDay/selectedDate), return dailySchedule
    if (selectedDay.value.toLowerCase() == (data.selectedDay ?? "").toLowerCase()) {
      return data.dailySchedule;
    }
    
    // Check in weeklySchedule map (case-insensitive key check if possible, or exact check)
    // The keys in weekly_schedule are typically "Monday", "Tuesday", etc.
    final scheduleKey = data.weeklySchedule.keys.firstWhere(
      (k) => k.toLowerCase() == selectedDay.value.toLowerCase(),
      orElse: () => selectedDay.value,
    );
    
    return data.weeklySchedule[scheduleKey] ?? [];
  }
}
