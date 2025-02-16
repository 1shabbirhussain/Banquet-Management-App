import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/services/firebase_services.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/views/manage_banquet_view/manage_banquet_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../custom_widgets/custom_drawer.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  State<OwnerHomeView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<OwnerHomeView> {
  FirebaseService firebaseService = FirebaseService();
  List<DocumentSnapshot> allBanquets = [];

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
        //APPBAR ***************************************
        appBar: AppBar(
          backgroundColor: MyColors.backgroundDark,
          title: const Center(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              width: 80,
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.bars,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.bell,
                color: Colors.white,
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.notificationScreen);
              },
            )
          ],
        ),
        //DRAWER ***************************************
        drawer: CustomDrawer(
          userName: userName, // Pass the user name from state
          userEmail: firebaseService.getCurrentUser()?.email ?? 'No Email',
          profilePictureUrl: profilePictureUrl, // Pass profile image from state
          isOwner: true, // Pass the user role
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          customHeaderWidget(context),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Banquets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: MyColors.textPrimary,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('banquets')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text(
                              "An error occurred while fetching banquets."));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("No banquets available."));
                    }

                    allBanquets = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['owner_id'] ==
                          FirebaseAuth.instance.currentUser?.uid;
                    }).toList();

                    return SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      width: MediaQuery.sizeOf(context).width,
                      child: Skeletonizer(
                        enabled:
                            snapshot.connectionState == ConnectionState.waiting,
                        enableSwitchAnimation: true,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                allBanquets.length > 3 ? 3 : allBanquets.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final banquet = allBanquets[index].data()
                                  as Map<String, dynamic>;
                              return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(AppRoutes.banquetDetailScreen,
                                        arguments: {
                                          'banquet': banquet,
                                          "hideButton": false
                                        });
                                  },
                                  child: BanquetCard(
                                    banquet: banquet,
                                    imageHeight: 85,
                                    imageWidth: 250,
                                    cardWidth: 250,
                                    buttonWidth: 100,
                                    buttonHeight: 30,
                                  ));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ]));
  }

//==============================================================================
// --------------------------------------- CUSTOM WIDGETS ----------------------
//==============================================================================

  Container customHeaderWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                        Get.toNamed(AppRoutes.manageBanquetScreen);
                      },
                    ),
                    _buildActionCard(
                      context,
                      title: "Manage Bookings",
                      icon: FontAwesomeIcons.calendarDays,
                      color: Colors.green,
                      onTap: () {
                        Get.toNamed(AppRoutes.ownerBookingsScreen);
                      },
                    ),
                    _buildActionCard(
                      context,
                      title: "Add Banquet",
                      icon: FontAwesomeIcons.circlePlus,
                      color: Colors.orange,
                      onTap: () {
                        Get.toNamed(AppRoutes.addBanquetScreen,
                            arguments: {'banquet': null});
                      },
                    ),
                    _buildActionCard(
                      context,
                      title: "Notifications",
                      icon: FontAwesomeIcons.bell,
                      color: Colors.blue,
                      onTap: () {
                        Get.toNamed(AppRoutes.notificationScreen);
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
