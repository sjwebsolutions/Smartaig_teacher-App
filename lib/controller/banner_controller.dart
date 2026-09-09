import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/banner_service.dart';
import '../models/banner_model.dart';
import '../services/fcm_services.dart';
import '../services/storage_services.dart';
import 'announcement_controller.dart';

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
        // Deduplicate banners by ID + imageUrl key to prevent Hero conflicts for identical items,
        // but allow banners with duplicate IDs but different images to show.
        final seenKeys = <String>{};
        final uniqueBanners = <BannerData>[];
        for (var b in result.banners!) {
          final key = "${b.id}_${b.imageUrl}";
          if (seenKeys.add(key)) {
            uniqueBanners.add(b);
          }
        }
        result.banners = uniqueBanners;
      }

      // Check for new banners to show notification dot and trigger sound
      if (result.banners != null && result.banners!.isNotEmpty) {
        final storedStr = await StorageService.getNotifiedBannerIds() ?? "";
        final seenIds = storedStr.split(',').where((s) => s.isNotEmpty).map(int.parse).toSet();

        final fetchedIds = result.banners!.map((b) => b.id).whereType<int>().toSet();
        final newIds = fetchedIds.difference(seenIds);

        if (newIds.isNotEmpty) {
          // Only show notification if we have seen banners before (to prevent login/startup spam)
          if (seenIds.isNotEmpty) {
            await FcmService.showLocalNotification(
              title: "New Banners Available",
              body: "Check out the latest school updates in the banners section.",
            );

            if (Get.isRegistered<AnnouncementController>()) {
              Get.find<AnnouncementController>().hasNewNotifications.value = true;
            }
          }

          // Save updated list of seen banner IDs to storage
          final updatedSeenIds = seenIds.union(fetchedIds);
          await StorageService.saveNotifiedBannerIds(updatedSeenIds.join(','));
        }
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
