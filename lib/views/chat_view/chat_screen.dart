import 'package:event_ease/controllers/chat_controller.dart';
import 'package:event_ease/custom_widgets/custom_text_field.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());

  final String ownerId;
  final String bookerId;
  final String bookingId;
  final TextEditingController messageController = TextEditingController();

  ChatScreen({super.key, required this.ownerId, required this.bookerId, required this.bookingId}) {
    chatController.initializeChat(ownerId, bookerId, bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat", style: TextStyle(color: MyColors.textSecondary)),
        backgroundColor: MyColors.backgroundDark,
        centerTitle: true,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              reverse: true,
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final message = chatController.messages[index];
                final isMine = message["sender_id"] == chatController.auth.currentUser?.uid;

                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine ? MyColors.buttonPrimary : MyColors.buttonSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            )),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: messageController,
                    label: "Type a message...",
                    hintText: "Enter message",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: MyColors.buttonPrimary),
                  onPressed: () {
                    chatController.sendMessage(messageController.text.trim());
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
