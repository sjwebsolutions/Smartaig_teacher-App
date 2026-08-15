import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/banner_service.dart';
import '../models/banner_model.dart';

class BannerController extends GetxController {
  final BannerServices _bannerServices = BannerServices();
  
  final banners = Rxn<BannerModel>();
  final currentBannerIndex = 0.obs;
  final isLoading = false.obs;

  Timer? _bannerTimer;
  final PageController bannerPageController = PageController(viewportFraction: 1.0);

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void _startBannerAutoSlider() {
    _bannerTimer?.cancel();
    if (banners.value?.banners == null || banners.value!.banners!.isEmpty) return;
    
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (banners.value?.banners != null && banners.value!.banners!.isNotEmpty) {
        int nextPage = (currentBannerIndex.value + 1) % banners.value!.banners!.length;
        currentBannerIndex.value = nextPage;
        
        if (bannerPageController.hasClients) {
          bannerPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuart,
          );
        }
      }
    });
  }

  Future<void> fetchBanners({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final result = await _bannerServices.getBanners();
      
      if (result.banners != null) {
        // Deduplicate banners by ID to prevent Hero tag conflicts
        final seenIds = <int>{};
        final uniqueBanners = <BannerData>[];
        for (var b in result.banners!) {
          if (b.id != null) {
            if (seenIds.add(b.id!)) {
              uniqueBanners.add(b);
            }
          } else {
            uniqueBanners.add(b);
          }
        }
        result.banners = uniqueBanners;
      }

      banners.value = result;
    } catch (e) {
      print("Error fetching banners: $e");
    } finally {
      isLoading.value = false;
      // Auto-scrolling disabled as requested
      // if (banners.value?.banners != null && banners.value!.banners!.isNotEmpty) {
      //   _startBannerAutoSlider();
      // }
    }
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }
}
