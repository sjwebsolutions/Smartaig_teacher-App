import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import 'app_bar_divider.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? customTitle;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leadingWidgets;
  final bool showDivider;
  final Color? backgroundColor;
  final bool? centerTitle;

  const AppTopBar({
    super.key,
    this.title,
    this.customTitle,
    this.showBack = true,
    this.actions,
    this.leadingWidgets,
    this.showDivider= true,
    this.backgroundColor,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
   // final bottomController = Get.find<BottomNavController>();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? AppColors.neutral,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,

      leading: showBack || leadingWidgets != null
          ? Padding(
        padding: const EdgeInsets.all(12),
        child: leadingWidgets ??
            IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                Get.back();
             //   bottomController.changeTab(0);
              },
            ),
      )
          : null,

      title: customTitle ??
          Text(
            title ?? "",
            style: AppTextStyles.appbarh4,
          ),

      actions: actions,

      bottom: showDivider ? AppBarDivider() : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 1);
}