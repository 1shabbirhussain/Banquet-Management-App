import 'package:event_ease/controllers/notification_icon_controller.dart';
import 'package:event_ease/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_ease/firebase_options.dart';
import 'package:event_ease/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  Get.put(NotificationController());


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EventEase',
      debugShowCheckedModeBanner: false, 
      initialRoute: AppRoutes.splash, 
      getPages: AppRoutes.routes,
      transitionDuration: const Duration(milliseconds: 300),
      defaultTransition: Transition.fadeIn,
    );
  }
}

