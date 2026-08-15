import 'package:flutter/material.dart';

import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';


class StudentPerformanceScreen extends StatelessWidget {
  const StudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final students = List.generate(8, (index) {
      return {
        "name": "Student ${index + 1}",
        "roll": "8A-10${index + 1}",
        "marks": "43/50",
        "status": index % 3 == 0
            ? "Exceeds Standards"
            : index % 3 == 1
            ? "Meeting Standards"
            : "Needs Support",
      };
    });

    return Scaffold(
      backgroundColor: AppColors.bgColor,

      appBar: AppTopBar(
        backgroundColor: AppColors.bgColor,

        showBack: true,
        showDivider: false,
        customTitle: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Student Performance", style: AppTextStyles.appbarh4),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 29, color: AppColors.red),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Class 8A",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.primary),

                const SizedBox(width: 12),

                Text(
                  "Mathematics",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Unit Test - 1",
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                _statBox("CLASS AVERAGE", "43.5/50"),
                const SizedBox(width: 12),
                _statBox("HIGHEST SCORE", "49/50"),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// AVATAR
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.grey.withOpacity(0.3),
                          child: const Icon(Icons.person),
                        ),

                        const SizedBox(width: 12),

                        /// NAME + ROLL
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s["name"]!,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Roll No - ${s["roll"]}",
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12,
                                  color: AppColors.black.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// MARKS + STATUS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              s["marks"]!,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 6),

                            _statusPill(s["status"]!),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey.withOpacity(0.2)),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [

              /// LEFT: EDIT
              InkWell(
                onTap: () {
                  // TODO: edit action
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Edit Marks",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                height: 40,
                width: 140, // shrink control
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    // TODO: submit report action
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 7,),
                      Icon(
                        Icons.file_download_outlined,
                        size: 18,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Export Report",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _statBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 10,
                color: AppColors.black.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color color;

    if (status == "Exceeds Standards") {
      color = AppColors.green;
    } else if (status == "Meeting Standards") {
      color = AppColors.primary;
    } else {
      color = AppColors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}