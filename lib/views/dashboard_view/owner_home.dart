import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/custom_widgets/custom_header_top_widget.dart';
import 'package:event_ease/services/firebase_services.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  State<OwnerHomeView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<OwnerHomeView> {
  FirebaseService firebaseService = FirebaseService();
  // --------------------------------------- slected category Start ------------------
  String userName = '';
  String profilePictureUrl = '';
  String gender = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  void fetchUserName() async {
    try {
      final User? currentUser = firebaseService.getCurrentUser();
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('owners')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? 'Guest';
            gender = userDoc['gender'] ?? 'Male';
            profilePictureUrl = (userDoc.data() as Map<String, dynamic>)
                    .containsKey('profile_picture_base64')
                ? userDoc['profile_picture_base64']
                : '';
          });
        } else {
          log('No user data found for the current user.');
        }
      } else {
        log('No user is logged in.');
      }
    } catch (e) {
      log('Error fetching user name: $e');
    }
  }

  int selectedCardIndex = -1;
  // --------------------------------------- slected category end ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: false,
        body: Column(children: [
          customHeaderWidget(context),
         
          const SizedBox(height: 30),
        ]));
  }

//==============================================================================
// --------------------------------------- CUSTOM WIDGETS ----------------------
//==============================================================================

  Container customHeaderWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      // height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MyColors.backgroundDark,
            MyColors.backgroundDark,
            MyColors.backgroundLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomHeaderTopWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Welcome Back! ",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: MyColors.white100),
                ),
              ),
               Center(
                 child: Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: MyColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
               ),

              //==============================================================================
               Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: GridView(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              children: [
                _buildActionCard(
                  context,
                  title: "Manage Banquets",
                  icon: FontAwesomeIcons.list,
                  color: Colors.deepPurple,
                  onTap: () {
                    // Navigate to Manage Banquets
                    Navigator.pushNamed(context, '/manage-banquets');
                  },
                ),
                _buildActionCard(
                  context,
                  title: "Manage Bookings",
                  icon: FontAwesomeIcons.calendarAlt,
                  color: Colors.green,
                  onTap: () {
                    // Navigate to Manage Bookings
                    Navigator.pushNamed(context, '/manage-bookings');
                  },
                ),
                _buildActionCard(
                  context,
                  title: "Add Banquet",
                  icon: FontAwesomeIcons.plusCircle,
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to Add Banquet Form
                    Navigator.pushNamed(context, '/add-banquet');
                  },
                ),
                _buildActionCard(
                  context,
                  title: "Notifications",
                  icon: FontAwesomeIcons.bell,
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to Notifications
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
              ],
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
