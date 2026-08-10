import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../controller/announcement_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final AnnouncementController controller = Get.find<AnnouncementController>();
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  String? _selectedTypeId;
  String _targetType = 'all'; // Default to 'all'
  DateTime? _fromDate;
  DateTime? _toDate;
  File? _selectedImage;

  final List<String> _selectedClassIds = [];
  final List<String> _selectedStreamIds = [];
  final List<String> _selectedSectionIds = [];

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now();
    _toDate = DateTime.now().add(const Duration(days: 2));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _selectedTypeId == null) {
      Get.snackbar("Error", "Please fill all required fields", 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final Map<String, dynamic> data = {
      'title': _titleController.text,
      'description': _descController.text,
      'type_id': _selectedTypeId,
      'from_date': DateFormat('yyyy-MM-dd').format(_fromDate!),
      'to_date': DateFormat('yyyy-MM-dd').format(_toDate!),
      'target_type': _targetType,
    };

    if (_targetType == 'specific') {
      // Add targeting data if specific
      for (int i = 0; i < _selectedClassIds.length; i++) {
        data['targets[$i][class_id]'] = _selectedClassIds[i];
      }
      // Similarly for streams and sections if needed by API
    }

    final success = await controller.createAnnouncement(
      data, 
      imagePath: _selectedImage?.path
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7FF),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppTopBar(
          showBack: true,
          title: "Create Announcement",
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Announcement Title *"),
              _buildTextField(
                controller: _titleController,
                hint: "Enter title",
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 16),

              _buildLabel("Description *"),
              _buildTextField(
                controller: _descController,
                hint: "Enter details...",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              _buildLabel("Announcement Type *"),
              Obx(() => _buildDropdownCard(
                icon: Icons.category_outlined,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTypeId,
                    hint: const Text("Select Type"),
                    items: controller.announcementTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['id'].toString(),
                        child: Text(type['name'] ?? ""),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTypeId = val),
                  ),
                ),
              )),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("From Date"),
                        _buildDateTile(
                          _fromDate, 
                          (date) => setState(() => _fromDate = date)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("To Date"),
                        _buildDateTile(
                          _toDate, 
                          (date) => setState(() => _toDate = date)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel("Target Audience"),
              Row(
                children: [
                  _buildTargetChip("All School", "all"),
                  const SizedBox(width: 10),
                  _buildTargetChip("Specific", "specific"),
                ],
              ),
              
              if (_targetType == 'specific') ...[
                const SizedBox(height: 16),
                _buildLabel("Select Classes"),
                Obx(() {
                  final classes = controller.targetingData['classes'] as List? ?? [];
                  return Wrap(
                    spacing: 8,
                    children: classes.map((c) {
                      final id = c['id'].toString();
                      final isSelected = _selectedClassIds.contains(id);
                      return FilterChip(
                        label: Text(c['name'] ?? ""),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selected ? _selectedClassIds.add(id) : _selectedClassIds.remove(id);
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  );
                }),
              ],

              const SizedBox(height: 20),
              _buildLabel("Attachment (Optional)"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: _selectedImage != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 40),
                          const SizedBox(height: 8),
                          Text("Click to upload image", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isCreating.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: controller.isCreating.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CREATE ANNOUNCEMENT", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(String label, String value) {
    final isSelected = _targetType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _targetType = value);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildDateTile(DateTime? date, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(date == null ? "Select" : DateFormat('dd/MM/yyyy').format(date)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdownCard({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
