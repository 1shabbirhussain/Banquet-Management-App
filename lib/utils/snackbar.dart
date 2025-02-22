import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  static void showSuccess(String message, {String title = "Success"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade400,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message, {String title = "Error"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade400,
      icon: Icons.error,
    );
  }

  static void showLoading(String message, {String title = "Loading"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade400,
      icon: Icons.hourglass_top,
      isLoading: true,
    );
  }

  // ✅ New Method: Show Info Snackbar
  static void showInfo(String message, {String title = "Info"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange.shade400, // Use orange for info
      icon: Icons.info,
    );
  }

  static void closeSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    bool isLoading = false,
  }) {
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: isLoading ? null : const Duration(seconds: 3), // Loading has no timeout
      showProgressIndicator: isLoading,
      progressIndicatorBackgroundColor: Colors.white,
      progressIndicatorValueColor: const AlwaysStoppedAnimation(Colors.white),
      isDismissible: !isLoading,
      margin: const EdgeInsets.all(10),
      barBlur: 10,
    );
  }
}