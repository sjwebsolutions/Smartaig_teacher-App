import 'package:get/get.dart';
import '../api_service/date_sheet_service.dart';
import '../models/date_sheet_model.dart';
import '../models/date_sheet_detail_model.dart';

class DateSheetController extends GetxController {
  final DateSheetService _service = DateSheetService();
  
  var isLoading = false.obs;
  var dateSheets = <DateSheetData>[].obs;
  var errorMessage = "".obs;
  var hasFetched = false.obs;

  // For details
  var isDetailLoading = false.obs;
  var dateSheetDetailWrapper = Rxn<DateSheetDetailWrapper>();

  @override
  void onInit() {
    print("DateSheetController Initialized");
    super.onInit();
    fetchDateSheets();
  }

  Future<void> fetchDateSheets() async {
    try {
      print("Controller: fetchDateSheets() called");
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _service.getDateSheets();
      print("Controller: success = ${response.success}");
      if (response.success == true && response.data != null) {
        print("Controller: items count = ${response.data!.length}");
        dateSheets.assignAll(response.data!);
      } else {
        print("Controller: response.success is false or data is null");
      }
      hasFetched.value = true;
    } catch (e) {
      print("Controller: catch error = $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("Controller: fetchDateSheets() finished. isLoading = ${isLoading.value}");
    }
  }

  Future<void> fetchDateSheetDetails(int id) async {
    try {
      isDetailLoading.value = true;
      dateSheetDetailWrapper.value = null;
      final response = await _service.getDateSheetDetails(id);
      if (response.success == true && response.data != null) {
        dateSheetDetailWrapper.value = response.data;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDetailLoading.value = false;
    }
  }
}
