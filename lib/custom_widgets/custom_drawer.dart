import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profilePictureUrl;
  final bool isOwner;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profilePictureUrl,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            color: MyColors.backgroundDark,
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            width: double.infinity,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? (profilePictureUrl.startsWith('http')
                              ? NetworkImage(profilePictureUrl)
                              : MemoryImage(base64Decode(profilePictureUrl)))
                          as ImageProvider
                      : const AssetImage('assets/images/default_avatar.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _drawerItem(
              FontAwesomeIcons.user,
              'My Profile',
              () => Get.toNamed(AppRoutes.profileScreen, arguments: {
                    'role': isOwner ? "Venue Owner" : "Venue Booker"
                  })),
          _drawerItem(
              FontAwesomeIcons.calendarCheck,
              isOwner ? "Manage Bookings" : "My Bookings",
              () => Get.toNamed(
                  isOwner ? AppRoutes.manageBookings : AppRoutes.myBookings)),
          _drawerItem(FontAwesomeIcons.bell, "Notifications",
              () => Get.toNamed(AppRoutes.notificationScreen)),
          _drawerItem(FontAwesomeIcons.commentDots, "Chat History",
              () => Get.toNamed(AppRoutes.chatInboxScreen)),
          const Divider(),
          // Add the "Need Help" tile
          _drawerItem(FontAwesomeIcons.headset, 'Need Help', () async {
            const phoneNumber = '+923158426173'; // WhatsApp number
            const whatsappUrl = 'https://wa.me/$phoneNumber';

            if (await canLaunchUrl(whatsappUrl as Uri)) {
              await launchUrl(whatsappUrl as Uri);
            } else {
              Get.snackbar(
                'Error',
                'Could not launch WhatsApp.',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_open),
            title: const Text('Close Drawer'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          _drawerItem(FontAwesomeIcons.powerOff, 'Log out', () async {
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.ownerLogin);
          }),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: FaIcon(icon, color: MyColors.backgroundDark),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(Get.context!); // Close drawer on tap
        onTap();
      },
    );
  }
}