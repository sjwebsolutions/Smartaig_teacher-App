import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/image_update_controller.dart';
import '../models/image_update_students_model.dart';
import '../models/image_update_store_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';
import 'widgets/custom_camera_screen.dart';
import 'widgets/punjabi_keyboard_helper.dart';

class UpdateStudentDetailsScreen extends StatefulWidget {
  const UpdateStudentDetailsScreen({super.key});

  @override
  State<UpdateStudentDetailsScreen> createState() => _UpdateStudentDetailsScreenState();
}

class _UpdateStudentDetailsScreenState extends State<UpdateStudentDetailsScreen> {
  final ImageUpdateController controller = Get.find<ImageUpdateController>();

  late ImageUpdateStudentData student;
  
  // Controllers for all model fields
  final _studentNameController = TextEditingController();
  final _studentNamePunjabiController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _fatherNamePunjabiController = TextEditingController();
  final _fatherQualificationController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherNamePunjabiController = TextEditingController();
  final _motherQualificationController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherMobileController = TextEditingController();
  final _studentMobileController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _bloodGroup = RxnString();

  @override
  void initState() {
    super.initState();
    final rawArgs = Get.arguments;
    if (rawArgs is ImageUpdateStudentData) {
      student = rawArgs;
    } else {
      student = ImageUpdateStudentData();
    }
    
    // Pre-fill existing data
    _studentNameController.text = student.studentName ?? "";
    _studentNamePunjabiController.text = student.studentNamePunjabi ?? "";
    _rollNoController.text = student.rollNo ?? "";
    _heightController.text = student.studentHeight?.toString() ?? "";
    _weightController.text = student.studentWeight?.toString() ?? "";
    _fatherNameController.text = student.fatherName ?? "";
    _fatherNamePunjabiController.text = student.fatherNamePunjabi ?? "";
    _fatherQualificationController.text = student.fatherQualification ?? "";
    _motherNameController.text = student.motherName ?? "";
    _motherNamePunjabiController.text = student.motherNamePunjabi ?? "";
    _motherQualificationController.text = student.motherQualification ?? "";
    _fatherMobileController.text = student.fatherMobile ?? "";
    _motherMobileController.text = student.motherMobile ?? "";
    _studentMobileController.text = student.studentMobile ?? "";
    _currentAddressController.text = student.currentAddress ?? "";
    _permanentAddressController.text = student.permanentAddress ?? "";
    _districtController.text = student.district ?? "";
    _stateController.text = student.state ?? "";
    _pincodeController.text = student.pincode ?? "";
    _bloodGroup.value = student.bloodGroup;
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentNamePunjabiController.dispose();
    _rollNoController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _fatherNameController.dispose();
    _fatherNamePunjabiController.dispose();
    _fatherQualificationController.dispose();
    _motherNameController.dispose();
    _motherNamePunjabiController.dispose();
    _motherQualificationController.dispose();
    _fatherMobileController.dispose();
    _motherMobileController.dispose();
    _studentMobileController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final result = await Get.to(() => const CustomCameraScreen());
    if (result != null) {
      await controller.saveCapturedImage(student.id!, type, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppTopBar(
          title: "Update Student Details",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentHeader(),
                const SizedBox(height: 20),
                
                const Text("CAPTURE IMAGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 10),
                _buildImagePickerRow("Student Profile", 'profile'),
                _buildImagePickerRow("Father's Image", 'father'),
                _buildImagePickerRow("Mother's Image", 'mother'),
                
                const SizedBox(height: 20),
                const Text("STUDENT DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 10),
                _buildTextField("Student Name", _studentNameController, isEnglishName: true, maxLength: 200),
                _buildTextField(
                  "Student Name (Punjabi) / ਵਿਦਿਆਰਥੀ ਦਾ ਨਾਮ", 
                  _studentNamePunjabiController, 
                  isPunjabi: true,
                  englishSourceController: _studentNameController,
                  maxLength: 200, 
                  hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਨਾਮ ਲਿਖੋ"
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Roll No", 
                        _rollNoController, 
                        keyboardType: TextInputType.number, 
                        maxLength: 4, 
                        maxNumericValue: 9999,
                        maxNumericMessage: "Roll No cannot exceed 9999",
                        hintText: "1 - 9999",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDropdownField("Blood Group", _bloodGroup)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Height (cm)", 
                        _heightController, 
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                        maxLength: 5, 
                        maxNumericValue: 250.0,
                        maxNumericMessage: "Height cannot be greater than 250 cm",
                        hintText: "30 - 250 cm",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        "Weight (kg)", 
                        _weightController, 
                        keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                        maxLength: 5, 
                        maxNumericValue: 250.0,
                        maxNumericMessage: "Weight cannot be greater than 250 kg",
                        hintText: "5 - 250 kg",
                      ),
                    ),
                  ],
                ),
                _buildTextField("Student Mobile", _studentMobileController, isPhone: true, hintText: "10-digit mobile number"),

                const SizedBox(height: 20),
                const Text("FATHER DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 10),
                _buildTextField("Father Name", _fatherNameController, isEnglishName: true, maxLength: 200),
                _buildTextField(
                  "Father Name (Punjabi) / ਪਿਤਾ ਦਾ ਨਾਮ", 
                  _fatherNamePunjabiController, 
                  isPunjabi: true,
                  englishSourceController: _fatherNameController,
                  maxLength: 200, 
                  hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਪਿਤਾ ਦਾ ਨਾਮ ਲਿਖੋ"
                ),
                _buildTextField("Father Qualification", _fatherQualificationController, maxLength: 100),
                _buildTextField("Father's Mobile", _fatherMobileController, isPhone: true, hintText: "10-digit mobile number"),

                const SizedBox(height: 20),
                const Text("MOTHER DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 10),
                _buildTextField("Mother Name", _motherNameController, isEnglishName: true, maxLength: 200),
                _buildTextField(
                  "Mother Name (Punjabi) / ਮਾਤਾ ਦਾ ਨਾਮ", 
                  _motherNamePunjabiController, 
                  isPunjabi: true,
                  englishSourceController: _motherNameController,
                  maxLength: 200, 
                  hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਮਾਤਾ ਦਾ ਨਾਮ ਲਿਖੋ"
                ),
                _buildTextField("Mother Qualification", _motherQualificationController, maxLength: 100),
                _buildTextField("Mother's Mobile", _motherMobileController, isPhone: true, hintText: "10-digit mobile number"),

                const SizedBox(height: 20),
                const Text("ADDRESS DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                const SizedBox(height: 10),
                _buildTextField("Current Address", _currentAddressController, maxLines: 2, maxLength: 500),
                _buildTextField("Permanent Address", _permanentAddressController, maxLines: 2, maxLength: 500),
                Row(
                  children: [
                    Expanded(child: _buildTextField("District", _districtController, maxLength: 100)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField("State", _stateController, maxLength: 100)),
                  ],
                ),
                _buildTextField("Pincode", _pincodeController, keyboardType: TextInputType.number, maxLength: 6, hintText: "6 digits"),
                
                const SizedBox(height: 30),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : () {
                      // Helper to show error
                      void showError(String msg) {
                        Get.snackbar(
                          "Validation Error", 
                          msg, 
                          backgroundColor: Colors.red, 
                          colorText: Colors.white, 
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(15),
                          borderRadius: 10,
                          duration: const Duration(seconds: 3),
                        );
                      }

                      // 1. Image Validation: At least one image must be provided
                      String? profile = controller.getCapturedImage(student.id!, 'profile');
                      String? father = controller.getCapturedImage(student.id!, 'father');
                      String? mother = controller.getCapturedImage(student.id!, 'mother');
                      if (profile == null && father == null && mother == null) {
                        showError("Please capture at least one image (Profile, Father, or Mother)");
                        return;
                      }

                      // 2. Mobile Validation: Exactly 10 digits
                      bool isValidPhone(String phone) {
                        if (phone.isEmpty) return true; // Optional but if provided must be 10 digits
                        return phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
                      }
                      if (!isValidPhone(_fatherMobileController.text)) return showError("Father's mobile must be 10 digits");
                      if (!isValidPhone(_motherMobileController.text)) return showError("Mother's mobile must be 10 digits");
                      if (!isValidPhone(_studentMobileController.text)) return showError("Student mobile must be 10 digits");

                      // 3. Roll No Validation: 1 to 9999
                      if (_rollNoController.text.isNotEmpty) {
                        int? roll = int.tryParse(_rollNoController.text);
                        if (roll == null || roll < 1 || roll > 9999) return showError("Roll No must be between 1 and 9999");
                      }

                      // 4. Height & Weight Validation (Height: 30-250 cm, Weight: 5-250 kg)
                      if (_heightController.text.isNotEmpty) {
                        double? h = double.tryParse(_heightController.text);
                        if (h == null || h < 30.0 || h > 250.0) return showError("Height must be between 30 and 250 cm");
                      }
                      if (_weightController.text.isNotEmpty) {
                        double? w = double.tryParse(_weightController.text);
                        if (w == null || w < 5.0 || w > 250.0) return showError("Weight must be between 5 and 250 kg");
                      }

                      // 5. Pincode Validation: 6 digits
                      if (_pincodeController.text.isNotEmpty && _pincodeController.text.length != 6) {
                        return showError("Pincode must be exactly 6 digits");
                      }

                      // 6. Max Character Checks
                      if (_currentAddressController.text.length > 500) return showError("Current Address max 500 characters");
                      if (_permanentAddressController.text.length > 500) return showError("Permanent Address max 500 characters");
                      if (_districtController.text.length > 100) return showError("District max 100 characters");
                      if (_stateController.text.length > 100) return showError("State max 100 characters");

                      final request = ImageUpdateStoreRequest(
                        studentId: student.id!,
                        profileImage: profile,
                        fatherImage: father,
                        motherImage: mother,
                        fatherMobile: _fatherMobileController.text,
                        motherMobile: _motherMobileController.text,
                        studentMobile: _studentMobileController.text,
                        bloodGroup: _bloodGroup.value,
                        rollNo: _rollNoController.text,
                        studentHeight: _heightController.text,
                        studentWeight: _weightController.text,
                        currentAddress: _currentAddressController.text,
                        permanentAddress: _permanentAddressController.text,
                        district: _districtController.text,
                        state: _stateController.text,
                        pincode: _pincodeController.text,
                        fatherQualification: _fatherQualificationController.text,
                        motherQualification: _motherQualificationController.text,
                        studentName: _studentNameController.text,
                        studentNamePunjabi: _studentNamePunjabiController.text,
                        fatherName: _fatherNameController.text,
                        fatherNamePunjabi: _fatherNamePunjabiController.text,
                        motherName: _motherNameController.text,
                        motherNamePunjabi: _motherNamePunjabiController.text,
                      );
                      
                      controller.submitRequest(
                        request: request,
                        onSuccess: () => Get.back(result: true),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: controller.isSubmitting.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SUBMIT REQUEST", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.studentName ?? "", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 2),
              Text("ID: ${student.studentUniqueId}", style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerRow(String title, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            
            Expanded(
              flex: 3,
              child: Obx(() {
                String? path = controller.getCapturedImage(student.id!, type);
                bool hasImage = path != null && File(path).existsSync();
                return Text(
                  hasImage ? "Image Selected" : "No Select Image",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasImage ? Colors.green : Colors.red.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
            
            GestureDetector(
              onTap: () => _pickImage(type),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Obx(() {
                  String? path = controller.getCapturedImage(student.id!, type);
                  if (path != null && File(path).existsSync()) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    );
                  }
                  return const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 26);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController textController, {
    TextInputType? keyboardType, 
    int maxLines = 1, 
    bool isPhone = false, 
    bool isEnglishName = false,
    bool isPunjabi = false,
    TextEditingController? englishSourceController,
    int? maxLength, 
    double? maxNumericValue,
    String? maxNumericMessage,
    String? hintText,
  }) {
    final int? effectiveMaxLength = maxLength ?? (isPhone ? 10 : null);

    List<TextInputFormatter> formatters = [];
    if (isPhone) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (isEnglishName) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\.\'\-]")));
    } else if (isPunjabi) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[\u0A00-\u0A7Fa-zA-Z0-9\s\.\,\-]')));
    } else if (keyboardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
    }

    if (effectiveMaxLength != null || maxNumericValue != null) {
      formatters.add(
        LengthLimitWithSnackbarFormatter(
          maxLength: effectiveMaxLength ?? 1000,
          fieldName: label,
          customLimitMessage: isPhone ? "$label: Maximum 10 digits allowed" : null,
          maxNumericValue: maxNumericValue,
          maxNumericMessage: maxNumericMessage,
        ),
      );
    }

    TextInputType resolvedKeyboardType = keyboardType ?? 
        (isPhone ? TextInputType.phone : (isEnglishName ? TextInputType.name : TextInputType.text));

    Widget? prefixWidget;
    if (isPhone) {
      prefixWidget = const Icon(Icons.phone_android, size: 22, color: AppColors.primary);
    } else if (isEnglishName) {
      prefixWidget = const Icon(Icons.person_outline, size: 22, color: AppColors.primary);
    } else if (isPunjabi) {
      prefixWidget = const Icon(Icons.translate, size: 22, color: AppColors.primary);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: textController,
            keyboardType: resolvedKeyboardType,
            textCapitalization: isEnglishName ? TextCapitalization.words : TextCapitalization.none,
            maxLines: maxLines,
            maxLength: effectiveMaxLength,
            inputFormatters: formatters,
            style: AppTextStyles.body.copyWith(
              fontSize: 16, 
              fontWeight: FontWeight.w500, 
              color: Colors.black87,
            ),
            onTap: isPunjabi ? () {
              showPunjabiKeyboard(
                context: context,
                controller: textController,
                title: label,
                englishSourceText: englishSourceController?.text,
                maxLength: effectiveMaxLength ?? 200,
              );
            } : null,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              counterText: "",
              labelStyle: const TextStyle(
                color: AppColors.primary, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
              ),
              floatingLabelStyle: const TextStyle(
                color: AppColors.primary, 
                fontSize: 15, 
                fontWeight: FontWeight.bold,
              ),
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: 0.6), 
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: prefixWidget,
              suffixIcon: isPunjabi
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (englishSourceController != null)
                          IconButton(
                            icon: const Icon(Icons.auto_fix_high, size: 22, color: AppColors.primary),
                            tooltip: "ਅੰਗਰੇਜ਼ੀ ਤੋਂ ਬਦਲੋ (Convert from English)",
                            onPressed: () {
                              if (englishSourceController.text.trim().isNotEmpty) {
                                final converted = PunjabiTransliteration.transliterate(englishSourceController.text);
                                textController.text = converted;
                                HapticFeedback.mediumImpact();
                                Get.snackbar(
                                  "ਪੰਜਾਬੀ ਵਿੱਚ ਬਦਲਿਆ (Converted)",
                                  "\"${englishSourceController.text}\" ➔ \"$converted\"",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: AppColors.primary,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(15),
                                  borderRadius: 10,
                                  duration: const Duration(seconds: 2),
                                );
                              } else {
                                Get.snackbar(
                                  "ਸੂਚਨਾ (Notice)",
                                  "ਕਿਰਪਾ ਕਰਕੇ ਪਹਿਲਾਂ ਅੰਗਰੇਜ਼ੀ ਨਾਮ ਦਰਜ ਕਰੋ (Please enter English name first)",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.orange.shade800,
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(15),
                                  borderRadius: 10,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_alt_outlined, size: 22, color: AppColors.primary),
                          tooltip: "ਪੰਜਾਬੀ ਕੀਬੋਰਡ ਖੋਲ੍ਹੋ (Open Punjabi Keyboard)",
                          onPressed: () {
                            showPunjabiKeyboard(
                              context: context,
                              controller: textController,
                              title: label,
                              englishSourceText: englishSourceController?.text,
                            );
                          },
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, RxnString selectedValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            hint: Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 24),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 8,
            menuMaxHeight: 300,
            style: AppTextStyles.body.copyWith(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            items: controller.formOptions.value?.bloodGroups?.map((group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.bloodtype_outlined, 
                        size: 20, 
                        color: selectedValue.value == group ? AppColors.primary : Colors.grey
                      ),
                      const SizedBox(width: 12),
                      Text(
                        group,
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedValue.value == group ? AppColors.primary : Colors.black87,
                          fontWeight: selectedValue.value == group ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) => selectedValue.value = value,
          ),
        ),
      )),
    );
  }
}

/// Custom TextInputFormatter that strictly restricts length & numeric limits
/// and shows a Top Snackbar notification when the user tries to type beyond the limit.
class LengthLimitWithSnackbarFormatter extends TextInputFormatter {
  final int maxLength;
  final String fieldName;
  final String? customLimitMessage;
  final double? maxNumericValue;
  final String? maxNumericMessage;
  static DateTime _lastSnackbarTime = DateTime.now().subtract(const Duration(seconds: 10));

  LengthLimitWithSnackbarFormatter({
    required this.maxLength,
    required this.fieldName,
    this.customLimitMessage,
    this.maxNumericValue,
    this.maxNumericMessage,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. If text is shortened (backspace / deletion), always allow
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // 2. Prevent exceeding character limit and notify
    if (newValue.text.length > maxLength) {
      _showLimitSnackbar(
        customLimitMessage ?? "$fieldName: Maximum $maxLength characters allowed",
      );
      return oldValue;
    }

    // 3. Prevent exceeding maximum numeric value (e.g. Height > 250, Weight > 250, Roll No > 9999)
    if (maxNumericValue != null && newValue.text.isNotEmpty) {
      final numVal = double.tryParse(newValue.text);
      if (numVal != null && numVal > maxNumericValue!) {
        _showLimitSnackbar(
          maxNumericMessage ?? "$fieldName cannot exceed $maxNumericValue",
        );
        return oldValue;
      }
    }

    return newValue;
  }

  static void _showLimitSnackbar(String message) {
    final now = DateTime.now();
    if (now.difference(_lastSnackbarTime).inMilliseconds > 1200) {
      _lastSnackbarTime = now;
      HapticFeedback.lightImpact();
      Get.snackbar(
        "Limit Reached",
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    }
  }
}
