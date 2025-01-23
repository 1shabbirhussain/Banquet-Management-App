import 'package:event_ease/routes/app_routes.dart';
import 'package:event_ease/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../services/firebase_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  void checkUserStatus() async {
    Map<String, dynamic> result = await _firebaseService.checkUserRole();
    bool isLoggedIn = result['isLoggedIn'];
    String? role = result['role'];

    if (isLoggedIn) {
      Get.offNamed(AppRoutes.navbar, arguments: {'role': role});
    } else {

      Get.offNamed(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: MyColors.backgroundDark,
        child: const Center(
          child: Icon(
            Icons.medical_services,
            size: 100,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
