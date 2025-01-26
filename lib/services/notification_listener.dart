import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/controllers/notification_icon_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

class BookingNotificationListener {
  static final NotificationController _notificationController = Get.find();

  static bool _isInitialLoad = true;

  // Debounce map to track notifications being processed
  static final Map<String, Timer> _debounceTimers = {};

  static void startListening({required String role}) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _isInitialLoad = true;

    if (role == "Venue Booker") {
      _listenForBookerNotifications(userId);
    } else if (role == "Venue Owner") {
      _listenForOwnerNotifications(userId);
    }
  }

  // Listener for Venue Booker
  static void _listenForBookerNotifications(String userId) {
    FirebaseFirestore.instance
        .collection('bookings')
        .where('booker_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }

      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.modified) {
          final data = doc.doc.data()!;
          final bookingId = doc.doc.id;

          // Debounce logic for status change notifications
          _debounce(bookingId, () {
            _handleStatusChangeNotification(data, bookingId);
          });
        }
      }
    });
  }

  // Listener for Venue Owner
  static void _listenForOwnerNotifications(String userId) {
    FirebaseFirestore.instance
        .collection('bookings')
        .where('owner_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }

      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data()!;
          final bookingId = doc.doc.id;

          // Debounce logic for new booking notifications
          _debounce(bookingId, () {
            _handleNewBookingNotification(data, bookingId);
          });
        }
      }
    });
  }

  static Future<void> _handleStatusChangeNotification(
      Map<String, dynamic> bookingData, String bookingId) async {
    final String status = bookingData['status'] ?? 'Unknown';
    final String banquetName = bookingData['banquet_name'] ?? 'Unknown';

    // Check if a notification already exists for this status change
    bool exists = await _checkNotificationExists(
      userId: bookingData['booker_id'],
      title: "Booking Status Updated",
      message: "Your booking for $banquetName is now $status.",
    );

    if (exists) {
      log("Notification already exists for this booking status change.");
      return;
    }

    // Add new notification flag
    _notificationController.addNewNotification();

    // Create notification in Firestore
    await _createNotificationInFirestore(
      bookingData['booker_id'],
      "Booking Status Updated",
      "Your booking for $banquetName is now $status.",
    );

    // Show local notification
    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "Booking Status Updated",
      body: "Your booking for $banquetName is now $status.",
    );
  }

  static Future<void> _handleNewBookingNotification(
      Map<String, dynamic> bookingData, String bookingId) async {
    final String banquetName = bookingData['banquet_name'] ?? 'Unknown';

    // Check if a notification already exists for this new booking
    bool exists = await _checkNotificationExists(
      userId: bookingData['owner_id'],
      title: "New Booking",
      message: "A new booking has been made for $banquetName.",
    );

    if (exists) {
      log("Notification already exists for this new booking.");
      return;
    }

    // Add new notification flag
    _notificationController.addNewNotification();

    // Create notification in Firestore
    await _createNotificationInFirestore(
      bookingData['owner_id'],
      "New Booking",
      "A new booking has been made for $banquetName.",
    );

    // Show local notification
    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "New Booking",
      body: "A new booking has been made for $banquetName.",
    );
  }

  // Check if a notification already exists
  static Future<bool> _checkNotificationExists({
    required String userId,
    required String title,
    required String message,
  }) async {
    final query = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notifications')
        .where('title', isEqualTo: title)
        .where('message', isEqualTo: message)
        .get();

    return query.docs.isNotEmpty;
  }

  // Create a notification in Firestore
  static Future<void> _createNotificationInFirestore(
      String userId, String title, String message) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('user_notifications')
          .add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Error creating notification in Firestore: $e");
    }
  }

  // Debounce function to limit the frequency of notifications
  static void _debounce(String key, VoidCallback action,
      [int milliseconds = 1000]) {
    if (_debounceTimers.containsKey(key)) {
      _debounceTimers[key]!.cancel();
    }

    _debounceTimers[key] = Timer(Duration(milliseconds: milliseconds), action);
  }
}
