
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class AppGradients {
  static LinearGradient primary({
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: const [

        Color(0xFFE3E9FF),
        Color(0xFFF9FAFD),
        Color(0xFFE8E3E3),
      ],
      begin: begin,
      end: end,
    );
  }
}
class AppColors {
  static const Color primary = Color(0xFF1D3777);
  static const Color neutral = Color(0xFFF8F9FA);
  static const Color grey = Color(0xFFDCDBDB);
  static const Color green = Color(0xFF4DB351);
  static const Color red = Color(0xFFD31A33);
  static const Color creamWhiteborder = Color(0xFFEBD5BB);
  static const Color creamWhite = Color(0xFFFCF4EA);
  static const Color brownattention = Color(0xFF7C2E12);
  static const Color attentiontheory = Color(0xFFB26651);
  static const Color blackColorText = Color(0xFF0C0A0A);
static const Color bgColor = Color(0xFFF8F9FA);
static const Color greensuccess = Color(0xFF059669);
  static const Color orange = Color(0xFFF69627);




  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color blacklight = Colors.black;
  static const Color transparent = Colors.transparent;




}