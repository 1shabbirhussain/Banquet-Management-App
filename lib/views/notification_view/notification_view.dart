import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: MyColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.textSecondary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(userId)
            .collection('user_notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Skeletonizer(
              enabled: true,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    subtitle: Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey[200],
                      margin: const EdgeInsets.only(top: 5),
                    ),
                  );
                },
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text("An error occurred while fetching notifications."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          final notifications = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    notifications[index].data() as Map<String, dynamic>;
                final timestamp = notification['timestamp'] != null
                    ? (notification['timestamp'] as Timestamp).toDate()
                    : null;

                return ListTile(
                  leading: const Icon(Icons.notifications,
                      color: MyColors.buttonSecondary),
                  title: Text(
                    notification['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['message'] ?? 'No Message',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (timestamp != null)
                        Text(
                          DateFormat('MMM d, yyyy, h:mm a').format(timestamp),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
