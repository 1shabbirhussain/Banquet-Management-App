import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/inbox_screen_controller.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatInboxController chatController = Get.put(ChatInboxController());

  @override
  void initState() {
    super.initState();
    chatController.fetchAllChatsWithBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat History",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        backgroundColor: MyColors.backgroundDark,
        centerTitle: true,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: Obx(() {
        if (chatController.chatList.isEmpty) {
          return const Center(
            child: Text(
              "No chats available",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: chatController.chatList.length,
          itemBuilder: (context, index) {
            final chat = chatController.chatList[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: MyColors.backgroundDark,
                child: Icon(Icons.event, color: Colors.white),
              ),
              title: Text(
                chat['banquetName'],
                style: const TextStyle(
                  color: MyColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Booking Date: ${_formatDate(chat['bookingDate'])}",
                style: const TextStyle(
                  color: MyColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: MyColors.textSecondary,
              ),
              onTap: () {
                Get.toNamed(
                  AppRoutes.chatScreen,
                  arguments: {
                    'ownerId': chat['ownerId'],
                    'bookerId': chat['bookerId'],
                    'bookingId': chat['bookingId'],
                  },
                );
              },
            );
          },
        );
      }),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy')
          .format(parsedDate); // Example: Feb 10, 2025
    } catch (e) {
      return 'Invalid Date'; // Fallback for invalid dates
    }
  }
}
