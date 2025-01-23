import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/custom_widgets/custom_text_field.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:event_ease/utils/snackbar.dart';
import 'package:event_ease/utils/validation_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final RxString selectedRole = ''.obs;
  final RxString genderController = ''.obs;
  final RxString profileImagePath = ''.obs; // Store image path temporarily
  final RxString profileImageBase64 = ''.obs; // Store Base64 string of image

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Retrieve data passed from ProfileView
    final arguments = Get.arguments ?? {};
    nameController.text = arguments['name'] ?? '';
    emailController.text = arguments['email'] ?? '';
    phoneController.text = arguments['phone'] ?? '';
    genderController.value = arguments['gender'] ?? 'Male';
    selectedRole.value = arguments['role'];
    // cityController.text = arguments['address'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(color: MyColors.white100)),
        elevation: 0,
        backgroundColor: MyColors.backgroundDark,
        iconTheme: const IconThemeData(color: MyColors.white100),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        _buildForm(context),
                        const Spacer(),
                        _buildSaveButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ///////////WIDGETS////////////////////
  Widget _buildHeader(BuildContext context) {
    // Retrieve the profile picture passed from the previous screen
    final passedImageBase64 = Get.arguments?['profile_picture_base64'] ?? '';
    final initialImageBytes =
        passedImageBase64.isNotEmpty ? base64Decode(passedImageBase64) : null;

    return Obx(() {
      return Column(
        children: [
          GestureDetector(
            onTap: () => _pickProfileImage(), // Open Image Picker
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profileImagePath.value.isNotEmpty
                  // Show the selected image
                  ? FileImage(File(profileImagePath.value))
                  : (initialImageBytes != null
                          ? MemoryImage(initialImageBytes)
                          : const NetworkImage(
                              'https://w7.pngwing.com/pngs/490/828/png-transparent-add-user-profile-person-avatar-account-emoticon-general-pack-icon.png'))
                      as ImageProvider,
              backgroundColor: MyColors.backgroundLight,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tap avatar to change profile picture",
            style: TextStyle(color: MyColors.primary),
          ),
        ],
      );
    });
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomTextFormField(
            controller: nameController,
            label: "Full Name",
            hintText: "Enter your full name",
            inputType: TextInputType.name,
            validator: (value) => value!.validateNotEmpty(),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: emailController,
            label: "Email",
            hintText: "Enter your email",
            inputType: TextInputType.emailAddress,
            validator: (value) => value!.validateEmail(),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: phoneController,
            label: "Phone Number",
            hintText: "Enter your phone number",
            inputType: TextInputType.phone,
            validator: (value) => value!.validatePhoneNumber(),
          ),
          const SizedBox(height: 20),
          _buildGenderSelection(),
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Obx(
      () {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text("Male"),
                value: "Male",
                groupValue: genderController.value,
                onChanged: (value) {
                  genderController.value = value!;
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: const Text("Female"),
                value: "Female",
                groupValue: genderController.value,
                onChanged: (value) {
                  genderController.value = value!;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  //////////////METHODS////////////////////////
  /////////////////////////////////////////////

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.buttonSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _saveProfileChanges(context),
        child: const Text("Save Changes",
            style: TextStyle(color: MyColors.textWhite)),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        profileImagePath.value = pickedFile.path;
        final bytes = await File(pickedFile.path).readAsBytes();
        profileImageBase64.value = base64Encode(bytes); // Encode to Base64
        log("Image picked and encoded as Base64");
      }
    } catch (e) {
      log("Error picking image: $e");
      SnackbarUtils.showError("Failed to pick image.");
    }
  }

  //ONPRESS SAVE PROFILE
  void _saveProfileChanges(BuildContext context) async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      SnackbarUtils.showError("All fields are required.");
      return;
    }

    try {
      // Show a loading snackbar
      SnackbarUtils.showLoading("Saving profile changes...");

      final userUid = Get.arguments?['uid'];
      final String collection =
          selectedRole.value == 'Venue Owner' ? 'owners' : 'bookers';

      // Updated data to save
      final updatedData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        // 'address': cityController.text.trim(),
        'gender': genderController.value,
        'profile_picture_base64': profileImageBase64.value.isNotEmpty
            ? profileImageBase64.value
            : Get.arguments?['profile_picture_base64'] ?? '',
      };

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userUid)
          .update(updatedData);

      // Dismiss loading snackbar
      if (Get.isSnackbarOpen) {
        Get.back();
      }
      // Show success message
      SnackbarUtils.showSuccess("Profile updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      // Dismiss loading snackbar if it's active
      if (Get.isSnackbarOpen) {
        Get.back();
      }

      // Show error message
      SnackbarUtils.showError("Failed to update profile: $e");
    }
  }
}
