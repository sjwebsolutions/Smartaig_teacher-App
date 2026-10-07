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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentHeader(),
                const SizedBox(height: 16),
                
                // Section 1: Photos
                _buildSectionCard(
                  title: "CAPTURE PHOTOS",
                  subtitle: "Upload student, father, and mother photos (Optional)",
                  icon: Icons.camera_alt_outlined,
                  children: [
                    _buildImagePickerRow("Student Profile", 'profile'),
                    _buildImagePickerRow("Father's Image", 'father'),
                    _buildImagePickerRow("Mother's Image", 'mother'),
                  ],
                ),

                // Section 2: Student Details
                _buildSectionCard(
                  title: "STUDENT DETAILS",
                  subtitle: "Basic student information",
                  icon: Icons.badge_outlined,
                  children: [
                    _buildTextField("Student Name", _studentNameController, isEnglishName: true, maxLength: 200),
                    _buildTextField(
                      "Student Name (Punjabi) / ਵਿਦਿਆਰਥੀ ਦਾ ਨਾਮ", 
                      _studentNamePunjabiController, 
                      isPunjabi: true,
                      englishSourceController: _studentNameController,
                      maxLength: 200, 
                      hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਨਾਮ ਲਿਖੋ",
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            prefixIcon: Icons.format_list_numbered_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdownField("Blood Group", _bloodGroup)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            prefixIcon: Icons.height_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            "Weight (kg)", 
                            _weightController, 
                            keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                            maxLength: 5, 
                            maxNumericValue: 250.0,
                            maxNumericMessage: "Weight cannot be greater than 250 kg",
                            hintText: "5 - 250 kg",
                            prefixIcon: Icons.monitor_weight_outlined,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField("Student Mobile", _studentMobileController, isPhone: true, hintText: "10-digit mobile number"),
                  ],
                ),

                // Section 3: Father Details
                _buildSectionCard(
                  title: "FATHER DETAILS",
                  subtitle: "Father's personal information",
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildTextField("Father Name", _fatherNameController, isEnglishName: true, maxLength: 200),
                    _buildTextField(
                      "Father Name (Punjabi) / ਪਿਤਾ ਦਾ ਨਾਮ", 
                      _fatherNamePunjabiController, 
                      isPunjabi: true,
                      englishSourceController: _fatherNameController,
                      maxLength: 200, 
                      hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਪਿਤਾ ਦਾ ਨਾਮ ਲਿਖੋ",
                    ),
                    _buildTextField("Father Qualification", _fatherQualificationController, maxLength: 100, prefixIcon: Icons.school_outlined),
                    _buildTextField("Father's Mobile", _fatherMobileController, isPhone: true, hintText: "10-digit mobile number"),
                  ],
                ),

                // Section 4: Mother Details
                _buildSectionCard(
                  title: "MOTHER DETAILS",
                  subtitle: "Mother's personal information",
                  icon: Icons.face_3_outlined,
                  children: [
                    _buildTextField("Mother Name", _motherNameController, isEnglishName: true, maxLength: 200),
                    _buildTextField(
                      "Mother Name (Punjabi) / ਮਾਤਾ ਦਾ ਨਾਮ", 
                      _motherNamePunjabiController, 
                      isPunjabi: true,
                      englishSourceController: _motherNameController,
                      maxLength: 200, 
                      hintText: "ਇੱਥੇ ਪੰਜਾਬੀ ਵਿੱਚ ਮਾਤਾ ਦਾ ਨਾਮ ਲਿਖੋ",
                    ),
                    _buildTextField("Mother Qualification", _motherQualificationController, maxLength: 100, prefixIcon: Icons.school_outlined),
                    _buildTextField("Mother's Mobile", _motherMobileController, isPhone: true, hintText: "10-digit mobile number"),
                  ],
                ),

                // Section 5: Address Details
                _buildSectionCard(
                  title: "ADDRESS DETAILS",
                  subtitle: "Permanent & communication address",
                  icon: Icons.location_on_outlined,
                  children: [
                    _buildTextField("Current Address", _currentAddressController, maxLines: 2, maxLength: 500, prefixIcon: Icons.home_outlined, fontSize: 13),
                    _buildTextField("Permanent Address", _permanentAddressController, maxLines: 2, maxLength: 500, prefixIcon: Icons.location_city_outlined, fontSize: 13),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTextField("District", _districtController, maxLength: 100, prefixIcon: Icons.map_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField("State", _stateController, maxLength: 100, prefixIcon: Icons.flag_outlined)),
                      ],
                    ),
                    _buildTextField("Pincode", _pincodeController, keyboardType: TextInputType.number, maxLength: 6, hintText: "6 digits", prefixIcon: Icons.pin_drop_outlined),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Submit Button
                Obx(() => Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value ? null : () {
                      debugPrint("==========================================");
                      debugPrint("🚀 [UpdateStudentDetailsScreen] SUBMIT REQUEST BUTTON CLICKED");
                      debugPrint("Student ID: ${student.id}");
                      debugPrint("Student Unique ID: ${student.studentUniqueId}");
                      debugPrint("Student Name: ${_studentNameController.text}");
                      debugPrint("Student Name (Punjabi): ${_studentNamePunjabiController.text}");
                      debugPrint("Roll No: ${_rollNoController.text}");
                      debugPrint("Blood Group: ${_bloodGroup.value}");
                      debugPrint("Height: ${_heightController.text}, Weight: ${_weightController.text}");
                      debugPrint("Father Name: ${_fatherNameController.text}, Mobile: ${_fatherMobileController.text}");
                      debugPrint("Mother Name: ${_motherNameController.text}, Mobile: ${_motherMobileController.text}");
                      debugPrint("Current Address: ${_currentAddressController.text}");
                      debugPrint("District: ${_districtController.text}, State: ${_stateController.text}, Pincode: ${_pincodeController.text}");
                      debugPrint("==========================================");

                      String? profile = controller.getCapturedImage(student.id!, 'profile');
                      String? father = controller.getCapturedImage(student.id!, 'father');
                      String? mother = controller.getCapturedImage(student.id!, 'mother');

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
                    icon: controller.isSubmitting.value 
                        ? const SizedBox.shrink() 
                        : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                    label: controller.isSubmitting.value 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text("SUBMIT REQUEST", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                )),
                const SizedBox(height: 24),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Center(
              child: Text(
                (student.studentName != null && student.studentName!.isNotEmpty)
                    ? student.studentName![0].toUpperCase()
                    : "S",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName ?? "Student Details",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ID: ${student.studentUniqueId ?? '-'}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (student.rollNo != null && student.rollNo!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Roll: ${student.rollNo}",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerRow(String title, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    String? path = controller.getCapturedImage(student.id!, type);
                    bool hasImage = path != null && File(path).existsSync();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasImage ? Colors.green.shade50 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasImage ? "Captured" : "Not Selected",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasImage ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(type),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  String? path = controller.getCapturedImage(student.id!, type);
                  if (path != null && File(path).existsSync()) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    );
                  }
                  return const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 24);
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
    IconData? prefixIcon,
    double? fontSize,
  }) {
    final int? effectiveMaxLength = maxLength ?? (isPhone ? 10 : null);

    List<TextInputFormatter> formatters = [];
    if (isPhone) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
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
    if (prefixIcon != null) {
      prefixWidget = Icon(prefixIcon, size: 20, color: AppColors.primary);
    } else if (isPhone) {
      prefixWidget = const Icon(Icons.phone_android_rounded, size: 20, color: AppColors.primary);
    } else if (isEnglishName) {
      prefixWidget = const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary);
    } else if (isPunjabi) {
      prefixWidget = const Icon(Icons.g_translate_rounded, size: 20, color: AppColors.primary);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
            style: TextStyle(
              fontSize: fontSize ?? 15, 
              fontWeight: FontWeight.w600, 
              color: const Color(0xFF1E293B),
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
              labelStyle: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.8), 
                fontSize: 13, 
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: const TextStyle(
                color: AppColors.primary, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
              ),
              hintStyle: TextStyle(
                color: Colors.grey.shade400, 
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: prefixWidget,
              suffixIcon: isPunjabi
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (englishSourceController != null)
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.auto_fix_high_rounded, size: 20, color: AppColors.primary),
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
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: const Icon(Icons.keyboard_alt_outlined, size: 20, color: AppColors.primary),
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
                      ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() => Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            hint: Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 22),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            menuMaxHeight: 280,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
            items: controller.formOptions.value?.bloodGroups?.map((group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Row(
                  children: [
                    Icon(
                      Icons.bloodtype_rounded, 
                      size: 18, 
                      color: selectedValue.value == group ? AppColors.primary : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      group,
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedValue.value == group ? AppColors.primary : Colors.black87,
                        fontWeight: selectedValue.value == group ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
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
