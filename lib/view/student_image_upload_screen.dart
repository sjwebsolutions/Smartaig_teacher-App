import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/image_update_controller.dart';
import '../models/image_update_students_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';
import 'widgets/custom_camera_screen.dart';

class StudentImageUploadScreen extends StatefulWidget {
  const StudentImageUploadScreen({super.key});

  @override
  State<StudentImageUploadScreen> createState() => _StudentImageUploadScreenState();
}

class _StudentImageUploadScreenState extends State<StudentImageUploadScreen> {
  final ImageUpdateController controller = Get.find<ImageUpdateController>();

  late ImageUpdateStudentData student;

  @override
  void initState() {
    super.initState();
    student = Get.arguments as ImageUpdateStudentData;
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
          title: "Upload Image",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentHeader(),
              const SizedBox(height: 20),
              _buildImagePickerRow("Student Profile", 'profile'),
              _buildImagePickerRow("Father's Image", 'father'),
              _buildImagePickerRow("Mother's Image", 'mother'),
              const SizedBox(height: 30),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () {
                    controller.submitRequest(
                      studentId: student.id!,
                      profileImage: controller.getCapturedImage(student.id!, 'profile'),
                      fatherImage: controller.getCapturedImage(student.id!, 'father'),
                      motherImage: controller.getCapturedImage(student.id!, 'mother'),
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
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.studentName ?? "", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("ID: ${student.studentUniqueId}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
                  fontSize: 11,
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
                    fontSize: 10,
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
}
