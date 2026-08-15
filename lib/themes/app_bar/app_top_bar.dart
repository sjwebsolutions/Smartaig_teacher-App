import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import 'app_bar_divider.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? customTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leadingWidgets;
  final bool showDivider;
  final Color? backgroundColor;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;

  const AppTopBar({
    super.key,
    this.title,
    this.customTitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.leadingWidgets,
    this.showDivider = false,
    this.backgroundColor,
    this.centerTitle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? AppColors.neutral,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: showBack || leadingWidgets != null
          ? (leadingWidgets ??
                  IconButton(
                    icon: const Icon(Icons.arrow_back_outlined),
                    onPressed: onBack ?? () => Get.back(),
                  ))
          : null,
      title: customTitle ??
          Text(
            title ?? "",
            style: AppTextStyles.appbarh4,
          ),
      actions: actions,
      bottom: bottom ?? (showDivider ? const AppBarDivider() : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? (showDivider ? 1 : 0)));
}
