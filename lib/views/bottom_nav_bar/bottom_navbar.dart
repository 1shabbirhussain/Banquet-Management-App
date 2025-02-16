import 'dart:developer';

import 'package:event_ease/controllers/notification_icon_controller.dart';
import 'package:event_ease/services/notification_listener.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/views/chat_view/inbox_screen.dart';
import 'package:event_ease/views/dashboard_view/booker_home.dart';
import 'package:event_ease/views/dashboard_view/owner_home.dart';
import 'package:event_ease/views/my_bookings_view/my_bookings_view.dart';
import 'package:event_ease/views/my_bookings_view/owner_booking_view.dart';
import 'package:event_ease/views/notification_view/notification_view.dart';
import 'package:event_ease/views/profile_view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavbarPage extends StatefulWidget {
  final String role;
  const NavbarPage({super.key, required this.role});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  final NotificationController _notificationController = Get.find();

  int _currentPage = 0;

  void _handleIndexChanged(int index) {
    setState(() {
      _currentPage = index;
      if (index == 2) {
        // If Notifications tab is clicked, mark notifications as read
        _notificationController.markNotificationsRead();
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
      BookingNotificationListener.startListening(role: widget.role); // Start listening to booking status changes

    log("Role: ${widget.role}");
    return Scaffold(
      body: _getPage(_currentPage),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: SizedBox(
          height: 60,
          child: GNav(
            backgroundColor: MyColors.backgroundDark,
            rippleColor: Colors.grey.shade800,
            hoverColor: Colors.grey.shade700,
            haptic: true,
            tabBorderRadius: 15,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 100),
            gap: 8,
            color: Colors.grey,
            activeColor: MyColors.textSecondary,
            iconSize: 20,
            textSize: 20,
            tabBackgroundColor: MyColors.accentDark.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tabMargin: const EdgeInsets.symmetric(horizontal: 5),
            tabs: [
              const GButton(
                icon: FontAwesomeIcons.house,
                text: 'Home',
              ),
              const GButton(
                icon: FontAwesomeIcons.calendarCheck,
                text: 'Bookings',
              ),
              // Notifications Tab with reactive icon

              GButton(
                icon: FontAwesomeIcons.bell, // Keep the bell icon constant
                text: 'Notifications',
                leading: Obx(
                  () => Stack(
                    children: [
                      const Icon(
                        FontAwesomeIcons.bell, // The main bell icon
                        size: 20,
                        color: Colors.grey,
                      ),
                      if (_notificationController.hasNewNotification
                          .value) // Show dot if new notification
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8, // Size of the dot
                            height: 8,
                            decoration: const BoxDecoration(
                              color: MyColors.textPrimary, // Red dot color
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const GButton(
                icon: FontAwesomeIcons.user,
                text: 'Profile',
              ),
            ],
            onTabChange: _handleIndexChanged,
          ),
        ),
      ),
    );
  }

  Widget _getPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return widget.role == 'Venue Owner'
            ? const OwnerHomeView()
            : const BookerHome();
      case 1:
        return widget.role == 'Venue Owner'
            ? const OwnerBookingsScreen()
            : const MyBookingsScreen();
      case 2:
        return InboxScreen();
      case 3:
        return ProfileView(role: widget.role);
      default:
        return Container();
    }
  }
}
