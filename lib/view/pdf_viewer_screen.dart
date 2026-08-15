import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final Map<String, dynamic> args = Get.arguments ?? {};
  late String url;
  late String title;
  bool isPageLoading = true;
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    url = args['url'] ?? "";
    title = args['title'] ?? "PDF Viewer";
  }

  Future<void> _sharePdfFile() async {
    if (url.isEmpty) return;

    try {
      setState(() {
        isSharing = true;
      });

      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/${title.replaceAll(' ', '_')}.pdf";
      
      // Download the file
      await Dio().download(url, filePath);

      // Share the file
      await Share.shareXFiles([XFile(filePath)], text: title);
      
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share PDF: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

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
        appBar: AppTopBar(
          title: title,
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: url.isNotEmpty
            ? Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SfPdfViewer.network(
                          url,
                          onDocumentLoaded: (details) {
                            setState(() {
                              isPageLoading = false;
                            });
                          },
                          onDocumentLoadFailed: (details) {
                            setState(() {
                              isPageLoading = false;
                            });
                            Get.snackbar(
                              "Error",
                              "Failed to load PDF: ${details.description}",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          },
                        ),
                      ),
                      
                      // Share Button at the bottom
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: isSharing ? null : _sharePdfFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            icon: isSharing 
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Icon(Icons.share_rounded, color: Colors.white),
                            label: Text(
                              isSharing ? "PREPARING FILE..." : "SHARE PDF FILE",
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Loader overlay
                  if (isPageLoading)
                    Container(
                      color: Colors.white.withValues(alpha: 0.8),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 15),
                            Text(
                              "Loading PDF...",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : const Center(
                child: Text("Invalid PDF URL"),
              ),
      ),
    );
  }
}
