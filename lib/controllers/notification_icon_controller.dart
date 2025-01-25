import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Reactive variable to track new notifications
  var hasNewNotification = false.obs;

  // Method to mark notifications as read
  void markNotificationsRead() {
    hasNewNotification.value = false;
  }

  // Method to trigger new notifications
  void addNewNotification() {
    hasNewNotification.value = true;
  }
}
