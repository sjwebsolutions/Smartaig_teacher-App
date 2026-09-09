import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final Map<String, dynamic> args = Get.arguments ?? {};
  late List<Map<String, dynamic>> files;
  late String title;
  int currentIndex = 0;
  bool isPageLoading = true;
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    title = args['title'] ?? "Viewer";
    
    // Support both single file (old way) and multiple files
    if (args['files'] != null) {
      files = List<Map<String, dynamic>>.from(args['files']);
    } else {
      files = [{
        'url': args['url'] ?? "",
        'isImage': args['isImage'] ?? false,
      }];
    }
    
    print("ViewerScreen Init: Title=$title, Files Count=${files.length}");
  }

  Future<void> _shareFile() async {
    final currentFile = files[currentIndex];
    final String url = currentFile['url'];
    final bool isImage = currentFile['isImage'];

    if (url.isEmpty) return;

    try {
      setState(() {
        isSharing = true;
      });

      final directory = await getTemporaryDirectory();
      final ext = isImage ? "jpg" : "pdf";
      final fileName = files.length > 1 ? "${title}_${currentIndex + 1}" : title;
      final filePath = "${directory.path}/${fileName.replaceAll(' ', '_')}.$ext";
      
      await Dio().download(url, filePath);
      await Share.shareXFiles([XFile(filePath)], text: title);
      
    } catch (e) {
      Get.snackbar("Error", "Failed to share file: $e", backgroundColor: Colors.red, colorText: Colors.white);
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
          title: files.length > 1 ? "$title (${currentIndex + 1}/${files.length})" : title,
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: files.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: files.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          isPageLoading = true;
                        });
                      },
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final String url = file['url'];
                        final bool isImage = file['isImage'];

                        if (isImage) {
                          return Center(
                            child: InteractiveViewer(
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white, size: 50),
                                imageBuilder: (context, imageProvider) {
                                  return Image(image: imageProvider, fit: BoxFit.contain);
                                },
                              ),
                            ),
                          );
                        } else {
                          return SfPdfViewer.network(
                            url,
                            onDocumentLoaded: (details) => setState(() => isPageLoading = false),
                            onDocumentLoadFailed: (details) {
                              setState(() => isPageLoading = false);
                              Get.snackbar("Error", "Failed to load PDF: ${details.description}", backgroundColor: Colors.red, colorText: Colors.white);
                            },
                          );
                        }
                      },
                    ),
                  ),
                  
                  // Share Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: isSharing ? null : _shareFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        icon: isSharing 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.share_rounded, color: Colors.white),
                        label: Text(
                          isSharing ? "PREPARING..." : "SHARE THIS FILE",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: Text("No files to display", style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
