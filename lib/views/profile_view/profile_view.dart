import 'dart:convert';
import 'dart:developer';

import 'package:event_ease/custom_widgets/custom_header_top_widget.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';


class ProfileView extends StatefulWidget {
  final String role;
  const ProfileView({super.key, required this.role});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String profilePictureUrl = '';
  bool isLoading = true;
  String city = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  ////////////////////////////////
  //////////////// METHOD START ////////////////
  ////////////////////////////////
  Future<void> fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        String collection =
            widget.role == 'Venue Owner' ? 'owners' : 'bookers';

        DocumentSnapshot userDoc =
            await _firestore.collection(collection).doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            final data = userDoc.data() as Map<String, dynamic>;

            profilePictureUrl = data.containsKey('profile_picture_base64')
                ? data['profile_picture_base64']
                : '';

            name = data.containsKey('name') ? data['name'] : 'N/A';
            email = data.containsKey('email') ? data['email'] : 'N/A';
            phone = data.containsKey('phone') ? data['phone'] : 'N/A';
            city = data.containsKey('city') ? data['city'] : 'N/A';
            gender = data.containsKey('gender') ? data['gender'] : 'N/A';
            isLoading = false;
          });
        } else {
          SnackbarUtils.showError('User data not found.');
        }
      }
    } catch (e) {
      log('Error: Failed to fetch user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  ////////////////////////////////
  //////////////// METHOD END ////////////////
  ////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Skeletonizer(
        enabled: isLoading,
        enableSwitchAnimation: true,
        child: Column(
          children: [
            customHeaderWidget(context),
            const SizedBox(height: 20),
            Expanded(child: customProfileBodyWidget(context)),
            const SizedBox(height: 10),
            editProfileButton(),
          ],
        ),
      ),
    );
  }

  //WIDGETS////////////////////////////////////////////

  Widget customProfileBodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildProfileDetail(
            context,
            icon: Icons.phone,
            title: "Phone Number",
            value: phone,
          ),
          const Divider(),
          _buildProfileDetail(
            context,
            icon: Icons.location_city,
            title: "City",
            value: city,
          ),
          const Divider(),
          _buildProfileDetail(
            context,
            icon: Icons.person,
            title: "Gender",
            value: gender,
          ),
        ]),
      ),
    );
  }

  Widget _buildProfileDetail(BuildContext context,
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: MyColors.buttonSecondary, size: 24),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container customHeaderWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomHeaderTopWidget(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? MemoryImage(base64Decode(profilePictureUrl))
                    : gender == "Male"
                        ? const NetworkImage(
                                "https://www.shareicon.net/data/128x128/2016/09/15/829459_man_512x512.png")
                            as ImageProvider
                        : const NetworkImage(
                                "https://avatar.iran.liara.run/public/93")
                            as ImageProvider,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              // Name and Email
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: MyColors.textSecondary),
              ),
              const SizedBox(),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget editProfileButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () async {
          await Get.toNamed(AppRoutes.editProfile, arguments: {
            'name': name,
            'email': email,
            'phone': phone,
            'city': city,
            'gender': gender,
            'role': widget.role,
            'uid': _auth.currentUser!.uid,
            'profile_picture_base64': profilePictureUrl,
          });
          setState(() {
            fetchUserData();
          });
        },
        child: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
