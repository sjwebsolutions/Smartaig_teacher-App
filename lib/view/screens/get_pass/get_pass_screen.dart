import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';
import '../../../controller/gate_pass_controller.dart';
import '../../../models/gate_pass_model.dart';
import '../../../utils/app_snackbar.dart';

class GetPassScreen extends StatelessWidget {
  const GetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GatePassController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const AppTopBar(
        title: "Get Pass",
        showBack: true,
        backgroundColor: Color(0xFFF8F9FE),
        showDivider: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasFetched.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error Occurred",
                    style: AppTextStyles.h2.copyWith(color: AppColors.red, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.fetchGatePasses(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        }

        if (controller.gatePasses.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchGatePasses(),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.badge_outlined, size: 54, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Gate Passes Found",
                        style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final activePass = controller.gatePasses.first;
        final recentPasses = controller.gatePasses.skip(1).toList();

        return RefreshIndicator(
          onRefresh: () => controller.fetchGatePasses(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNewPassButton(context),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "Active Pass",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActivePassCard(activePass),
                if (recentPasses.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "Recent Passes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecentPassesList(recentPasses),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNewPassButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF384C8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRequestPassBottomSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Text(
                "Request New Gate Pass",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePassCard(GatePassData pass) {
    Color statusColor = Colors.grey;
    if (pass.status?.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else if (pass.status?.toLowerCase() == 'approved') {
      statusColor = AppColors.greensuccess;
    } else if (pass.status?.toLowerCase() == 'rejected' || pass.status?.toLowerCase() == 'denied') {
      statusColor = AppColors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "RELATION",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (pass.relation ?? "Self").toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (pass.status ?? "PENDING").toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 18),
          
          // Grid Detail Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildPassDetail(
                  "Date", 
                  pass.date ?? "N/A", 
                  Icons.calendar_month_rounded,
                ),
              ),
              Expanded(
                child: _buildPassDetail(
                  "Exit Time", 
                  pass.exitTime ?? "N/A", 
                  Icons.login_rounded,
                ),
              ),
              Expanded(
                child: _buildPassDetail(
                  "Req Time", 
                  pass.time ?? "N/A", 
                  Icons.access_time_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 18),
          
          // Reason and Details
          _buildPassDetailLong("Reason", pass.reason ?? "N/A", Icons.description_rounded),
          if (pass.personName != null && pass.personName!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildPassDetailLong("Visitor Name", pass.personName!, Icons.person_rounded),
          ],
          if (pass.contactNo != null && pass.contactNo!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildPassDetailLong("Contact No", pass.contactNo!, Icons.phone_android_rounded),
          ],
          
          // QR Code frame
          if (pass.gatePassNo != null && pass.gatePassNo!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 84, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    pass.gatePassNo!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPassDetail(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPassDetailLong(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPassesList(List<GatePassData> recentPasses) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentPasses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pass = recentPasses[index];
        Color statusColor = Colors.grey;
        if (pass.status?.toLowerCase() == 'pending') {
          statusColor = Colors.orange;
        } else if (pass.status?.toLowerCase() == 'approved') {
          statusColor = AppColors.greensuccess;
        } else if (pass.status?.toLowerCase() == 'rejected' || pass.status?.toLowerCase() == 'denied') {
          statusColor = AppColors.red;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass.gatePassNo ?? "Gate Pass",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Reason: ${pass.reason ?? 'N/A'}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pass.date ?? "",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (pass.status ?? "pending").toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRequestPassBottomSheet(BuildContext context) {
    final controller = Get.find<GatePassController>();
    final reasonController = TextEditingController();
    final exitTimeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> selectExitTime() async {
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
        exitTimeController.text = "$hour:$minute";
      }
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag bar indicator
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Request Gate Pass",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
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
                  controller: exitTimeController,
                  readOnly: true,
                  onTap: selectExitTime,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? "Please select exit time" : null,
                  decoration: InputDecoration(
                    hintText: "Select exit time (e.g. 17:30)",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                
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
                  controller: reasonController,
                  maxLines: 3,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? "Please enter reason" : null,
                  decoration: InputDecoration(
                    hintText: "e.g., Personal bank work and document submission",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),
                
                // Submit Button
                Obx(() {
                  final isSubmitting = controller.isLoading.value;
                  return Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: isSubmitting
                          ? null
                          : const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF384C8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(14),
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
                              if (formKey.currentState?.validate() ?? false) {
                                try {
                                  final success = await controller.requestGatePass(
                                    reason: reasonController.text,
                                    exitTime: exitTimeController.text,
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
                          borderRadius: BorderRadius.circular(14),
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
        ),
      ),
      isScrollControlled: true,
    );
  }
}
