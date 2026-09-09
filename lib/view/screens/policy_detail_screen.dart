import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/appColors_&_styles/text_styles.dart';

class PolicyDetailScreen extends StatelessWidget {
  final String title;
  final String htmlContent;

  const PolicyDetailScreen({
    super.key,
    required this.title,
    required this.htmlContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            title,
            style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 22),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: HtmlWidget(
              htmlContent,
              textStyle: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
              customStylesBuilder: (element) {
                if (element.localName == 'h1') {
                  return {
                    'font-size': '20px',
                    'font-weight': 'bold',
                    'color': '#0d47a1', // Match AppColors.primary
                    'margin-bottom': '12px',
                    'margin-top': '4px',
                  };
                }
                if (element.localName == 'p') {
                  return {
                    'margin-bottom': '16px',
                  };
                }
                if (element.localName == 'strong') {
                  return {
                    'font-weight': 'bold',
                  };
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}
