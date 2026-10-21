import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle ?? true,
      leading: showBack || leadingWidgets != null
          ? (leadingWidgets ??
              Center(
                child: GestureDetector(
                  onTap: onBack ?? () => Get.back(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
              ))
          : null,
      title: customTitle ??
          Text(
            (title ?? "").toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
      actions: actions,
      bottom: bottom ?? (showDivider ? const AppBarDivider() : null),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? (showDivider ? 1 : 0)));
}
