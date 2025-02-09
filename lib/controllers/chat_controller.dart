import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var messages = <Map<String, dynamic>>[].obs; // Stores chat messages
  String chatId = "";

  /// Initializes the chat by creating or fetching an existing chat document
  void initializeChat(String ownerId, String bookerId, String bookingId) {
    chatId = "${ownerId}_${bookerId}_$bookingId"; // Unique chat document ID

    // Listen for new messages in real-time
    _firestore.collection("chats").doc(chatId).collection("messages")
      .orderBy("timestamp", descending: true)
      .snapshots().listen((snapshot) {
        messages.value = snapshot.docs.map((doc) => doc.data()).toList();
      });

    // Create chat document if it doesn't exist
    _firestore.collection("chats").doc(chatId).set({
      "owner_id": ownerId,
      "booker_id": bookerId,
      "booking_id": bookingId,
    }, SetOptions(merge: true));
  }

  /// Sends a new message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) return;

    final messageData = {
      "sender_id": currentUserId,
      "text": text,
      "timestamp": FieldValue.serverTimestamp(),
    };

    await _firestore.collection("chats").doc(chatId).collection("messages").add(messageData);
  }
}
