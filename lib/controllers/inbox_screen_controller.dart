import 'dart:developer'; // ✅ Add this for logging
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatInboxController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var chatList = <Map<String, dynamic>>[].obs; // Store chats with booking details

  /// Fetches all chats and combines with booking details
  void fetchAllChatsWithBookings() async {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      log("No current user logged in");
      return;
    }

    log("Fetching chats for user: $currentUserId");

    _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('owner_id', isEqualTo: currentUserId),
          Filter('booker_id', isEqualTo: currentUserId),
        ))
        .snapshots()
        .listen((chatSnapshot) async {
      List<Map<String, dynamic>> tempChatList = [];

      if (chatSnapshot.docs.isEmpty) {
        log("No chats found for user: $currentUserId");
        chatList.value = [];
        return;
      }

      // Collect booking IDs for batch query
      List<String> bookingIds = chatSnapshot.docs
          .map((doc) => doc['booking_id'] as String? ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      log("Booking IDs from chats: $bookingIds");

      if (bookingIds.isEmpty) {
        log("No booking IDs found in chats.");
        chatList.value = [];
        return;
      }

      try {
        // Fetch all bookings at once using whereIn
        var bookingsSnapshot = await _firestore
            .collection('bookings')
            .where(FieldPath.documentId, whereIn: bookingIds)
            .get();

        // Log the raw booking documents
        log("Fetched ${bookingsSnapshot.docs.length} bookings for IDs: $bookingIds");

        // Create a map of booking details for quick access
        Map<String, dynamic> bookingsMap = {
          for (var doc in bookingsSnapshot.docs) doc.id: doc.data(),
        };

        log("Bookings Map: ${bookingsMap.toString()}");

        // Merge chat data with booking data
        for (var chatDoc in chatSnapshot.docs) {
          final chatData = chatDoc.data();
          final bookingId = chatData['booking_id'];
          final bookingDetails = bookingsMap[bookingId];

          log("Merging chat with bookingId: $bookingId, Found: ${bookingDetails != null}");

          tempChatList.add({
            "chatId": chatDoc.id,
            "banquetName": bookingDetails?['banquet_name'] ?? 'Unknown Banquet',
            "bookingDate": bookingDetails?['date'] ?? 'No Date',
            "ownerId": chatData['owner_id'],
            "bookerId": chatData['booker_id'],
            "bookingId": bookingId,
          });
        }

        // Log the final merged chat list
        log("Final Chat List: ${tempChatList.toString()}");

        // Update the observable list to trigger UI refresh
        chatList.value = tempChatList;
      } catch (e) {
        log("Error fetching bookings: $e");
      }
    });
  }
}
