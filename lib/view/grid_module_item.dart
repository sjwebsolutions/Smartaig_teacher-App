import 'dart:ui';

import 'package:flutter/material.dart';

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isEnabled = true,
  });
}
