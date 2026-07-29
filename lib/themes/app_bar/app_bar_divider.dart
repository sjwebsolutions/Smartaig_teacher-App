import 'package:flutter/material.dart';

import '../appColors_&_styles/app_Colors.dart';
class AppBarDivider extends StatelessWidget implements PreferredSizeWidget {
  const AppBarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      //color: Colors.grey.shade300,
      color: AppColors.grey,

    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(1);
}