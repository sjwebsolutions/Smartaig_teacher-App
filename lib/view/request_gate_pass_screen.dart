import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/gate_pass_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../utils/app_snackbar.dart';

class RequestGatePassScreen extends StatefulWidget {
  const RequestGatePassScreen({super.key});

  @override
  State<RequestGatePassScreen> createState() => _RequestGatePassScreenState();
}

class _RequestGatePassScreenState extends State<RequestGatePassScreen> {
  final _reasonController = TextEditingController();
  final _exitTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectExitTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _exitTimeController.text = "$hour:$minute";
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _exitTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GatePassController>();

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppTopBar(
          title: "REQUEST GATE PASS",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exit Time Field
                        const Text(
                          "Exit Time",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _exitTimeController,
                          readOnly: true,
                          onTap: _selectExitTime,
                          validator: (value) =>
                              (value == null || value.isEmpty) ? "Please select exit time" : null,
                          decoration: InputDecoration(
                            hintText: "Select exit time (e.g. 17:30)",
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                            prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Reason Field
                        const Text(
                          "Reason",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 4,
                          validator: (value) =>
                              (value == null || value.isEmpty) ? "Please enter reason" : null,
                          decoration: InputDecoration(
                            hintText: "e.g., Personal bank work and document submission",
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        Obx(() {
                          final isSubmitting = controller.isLoading.value;
                          return Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSubmitting ? Colors.grey : AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (!isSubmitting)
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        try {
                                          final success = await controller.requestGatePass(
                                            reason: _reasonController.text,
                                            exitTime: _exitTimeController.text,
                                          );
                                          if (success) {
                                            Get.back();
                                            AppSnackBar.success(
                                                "Gate pass requested successfully!");
                                          } else {
                                            AppSnackBar.error(
                                                "Failed to request gate pass");
                                          }
                                        } catch (e) {
                                          AppSnackBar.error(e.toString());
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSubmitting
                                  ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                  : const Text(
                                      "Submit Request",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
