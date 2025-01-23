import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/services/firebase_services.dart';
import 'package:event_ease/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController ownerLoginEmailController = TextEditingController();
  final TextEditingController ownerLoginPasswordController = TextEditingController();

  final TextEditingController bookerLoginEmailController = TextEditingController();
  final TextEditingController bookerLoginPasswordController = TextEditingController();

  // Reactive Variables
  final RxString selectedRole = 'Venue Booker'.obs;
  final RxString genderController = 'Male'.obs;
  final RxBool termsAccepted = false.obs;
  final RxString selectedCity = ''.obs;

  // Dispose controllers when the controller is removed
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    ownerLoginEmailController.dispose();
    ownerLoginPasswordController.dispose();
    bookerLoginEmailController.dispose();
    bookerLoginPasswordController.dispose();
    super.onClose();
  }

  // Sign In Method
  Future<void> signIn(String role, {required bool isOwner}) async {
  FocusScope.of(Get.context!).unfocus();

  TextEditingController emailCtrl =
      isOwner ? ownerLoginEmailController : bookerLoginEmailController;
  TextEditingController passwordCtrl =
      isOwner ? ownerLoginPasswordController : bookerLoginPasswordController;

  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
    SnackbarUtils.showError("Email and Password cannot be empty.");
    return;
  }

  try {
    SnackbarUtils.showLoading("Processing login request...");
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text.trim(),
    );

    final User? user = userCredential.user;

    if (user != null) {
      String? userRole = await _getUserRole(user.uid, role);
      SnackbarUtils.closeSnackbar();

      if (userRole == role) {
        SnackbarUtils.showSuccess("Login successful!");
        await Get.offAllNamed(AppRoutes.navbar, arguments: {'role': role});
      } else {
        SnackbarUtils.showError(
            "Incorrect role. Please sign in with the correct role.");
      }
    }
  } on FirebaseAuthException catch (e) {
    SnackbarUtils.closeSnackbar();
    log("Error signing in: $e e.code: ${e.code}");

    String message;
    if (e.code == 'invalid-email') {
      message = 'No user found for this email.';
    } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
      message = 'Invalid credential provided.';
    } else {
      message = 'An error occurred. Please try again.';
    }

    SnackbarUtils.showError(message);
  } catch (e) {
    SnackbarUtils.closeSnackbar();
    SnackbarUtils.showError("An error occurred: $e");
  }
}


  // Fetch user role
Future<String?> _getUserRole(String uid , String role) async {
  try {
    log("Fetching role for user ID: $uid");

    // Dynamically determine the collection based on the user's role
    final collection = role == 'Venue Owner' ? 'owners' : 'bookers';

    DocumentSnapshot userDoc = await _firestore.collection(collection).doc(uid).get();

    if (userDoc.exists && userDoc['role'] != null) {
      log("Role found: ${userDoc['role']}");
      return userDoc['role']; // Return the role from Firestore
    }

    log("No role found for user ID: $uid");
    return null;
  } catch (e) {
    log("Error fetching user role: $e");
    return null;
  }
}


  // Sign Up Method
  Future<void> signUp() async {
    try {
      if (!formKey.currentState!.validate()) {
        SnackbarUtils.showError("Please fill all fields correctly.");
        return;
      }

      if (!termsAccepted.value) {
        SnackbarUtils.showError("You must accept the Terms and Conditions to continue.");
        return;
      }

      SnackbarUtils.showLoading("Processing register request...");
      FocusScope.of(Get.context!).unfocus();

      User? user = await _firebaseService.signUp(
          emailController.text.trim(), passwordController.text.trim());

      if (user != null) {
        final userData = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': selectedRole.value,
          'gender': genderController.value,
          'uid': user.uid,
          'city': selectedCity.value,
          'created_at': DateTime.now(),
        };

        // Save user data to Firestore in respective collection
        final collection = selectedRole.value == 'Venue Owner' ? 'owners' : 'bookers';
        await _firestore.collection(collection).doc(user.uid).set(userData);

        SnackbarUtils.closeSnackbar();
        SnackbarUtils.showSuccess("Registration successful!");

        // Navigate to the home screen
        Get.offAllNamed(AppRoutes.navbar, arguments: {'role': selectedRole.value});
      }
    } on FirebaseAuthException catch (e) {
      SnackbarUtils.closeSnackbar();
      String errorMessage = e.code == 'email-already-in-use'
          ? "This email is already in use."
          : "Registration failed. Please try again.";
      SnackbarUtils.showError(errorMessage);
    } catch (e) {
      SnackbarUtils.closeSnackbar();
      SnackbarUtils.showError("Registration failed: $e");
    }
  }
}
