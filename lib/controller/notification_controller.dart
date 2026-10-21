import 'dart:async';
import 'package:get/get.dart';
import '../api_service/notification_service.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final hasNewNotifications = false.obs;
  final unreadCount = 0.obs;
  final selectedFilter = 'all'.obs;
  
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final hasMore = false.obs;
  final retentionDays = 7.obs;
  final totalCount = 0.obs;

  Timer? _autoSyncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();

    // Auto-sync unread count every 20 seconds in background
    _autoSyncTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      fetchUnreadCount();
    });
  }

  @override
  void onClose() {
    _autoSyncTimer?.cancel();
    super.onClose();
  }

  int get calculatedUnreadCount {
    final unreadInList = notifications.where((item) => item.isRead == false).length;
    if (unreadCount.value > 0) {
      return unreadCount.value;
    }
    return unreadInList;
  }

  List<NotificationItem> get filteredNotifications {
    if (selectedFilter.value == 'all') {
      return notifications;
    }
    if (selectedFilter.value == 'unread') {
      return notifications.where((item) => item.isRead == false).toList();
    }
    
    final filter = selectedFilter.value.toLowerCase().trim();

    return notifications.where((item) {
      final module = item.displayModule.toLowerCase().trim();
      final title = item.displayTitle.toLowerCase().trim();
      final body = item.displayBody.toLowerCase().trim();

      if (filter == 'student_leaves' || filter == 'student leaves') {
        final isStudent = module.contains('student') ||
            title.contains('student') ||
            body.contains('student');
        final isLeave = module.contains('leave') ||
            title.contains('leave') ||
            body.contains('leave');
        return isStudent && isLeave;
      }

      if (filter == 'teacher_leaves' || filter == 'teacher leaves') {
        final isStudent = module.contains('student') ||
            title.contains('student') ||
            body.contains('student');
        final isLeave = module.contains('leave') ||
            module == 'leaves' ||
            title.contains('leave') ||
            body.contains('leave') ||
            body.contains('your leave');
        return isLeave && !isStudent;
      }

      return module == filter || module.contains(filter) || filter.contains(module);
    }).toList();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
      }
      isLoading.value = true;

      final result = await _service.getNotifications(page: currentPage.value);
      
      if (result.data != null) {
        final container = result.data!;
        retentionDays.value = container.retentionDays ?? 7;

        if (container.pagination != null) {
          lastPage.value = container.pagination!.lastPage ?? 1;
          hasMore.value = container.pagination!.hasMore ?? false;
          totalCount.value = container.pagination!.total ?? 0;
        }

        final newList = container.notifications ?? [];
        if (currentPage.value == 1) {
          notifications.value = newList;
        } else {
          notifications.addAll(newList);
        }
      }
      await fetchUnreadCount();
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      unreadCount.value = count;
      hasNewNotifications.value = count > 0;
    } catch (e) {
      print("Error fetching unread count: $e");
    }
  }

  Future<void> markSingleAsRead(NotificationItem item) async {
    if (item.isRead == false) {
      item.isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
      if (unreadCount.value == 0) {
        hasNewNotifications.value = false;
      }
      if (item.id != null) {
        await _service.markAsRead(item.id);
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (var item in notifications) {
      item.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    hasNewNotifications.value = false;
    await _service.markAllRead();
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore.value) return;
    try {
      isMoreLoading.value = true;
      currentPage.value += 1;
      await fetchNotifications();
    } finally {
      isMoreLoading.value = false;
    }
  }

  void markAsRead() {
    unreadCount.value = 0;
    hasNewNotifications.value = false;
  }
}
