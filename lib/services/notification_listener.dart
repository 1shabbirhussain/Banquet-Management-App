import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/controllers/notification_icon_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

class BookingNotificationListener {
    static final NotificationController _notificationController = Get.find();
  // Start listening to bookings for the current user
  static void startListening() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Listen to changes in bookings for the current user
    FirebaseFirestore.instance
        .collection('bookings')
        .where('booker_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.modified) {
          final data = doc.doc.data()!;
          _handleBookingStatusChange(data);
        }
      }
    });
  }

  // Handle booking status change
  static Future<void> _handleBookingStatusChange(
      Map<String, dynamic> bookingData) async {
    final String status = bookingData['status'] ?? 'Unknown';
    final String banquetName = bookingData['banquet_name'] ?? 'Unknown';

    log("Status updated for booking: ${bookingData['id']}, Status: $status");
    _notificationController.addNewNotification();

    // Create a notification in Firestore
    await _createNotificationInFirestore(
        bookingData['booker_id'], status, "Your booking for $banquetName is now $status.");

    // Trigger a local notification
    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "Booking Status Updated",
      body: "Your booking for $banquetName is now $status.",
    );
  }

  // Create a Firestore notification
  static Future<void> _createNotificationInFirestore(
      String userId, String status, String message) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': userId,
        'title': status,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error creating notification in Firestore: $e");
    }
  }
}
