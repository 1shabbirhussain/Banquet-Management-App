import 'package:event_ease/bindings/auth_bindings.dart';
import 'package:event_ease/views/add_banquet_view/add_banquet_screen.dart';
import 'package:event_ease/views/authentication_view/owner_login.dart';
import 'package:event_ease/views/authentication_view/booker_login.dart';
import 'package:event_ease/views/authentication_view/register_view.dart';
import 'package:event_ease/views/banquet_detail_view/banquest_detail_view.dart';
import 'package:event_ease/views/banquet_detail_view/booking_screen.dart';
import 'package:event_ease/views/banquet_detail_view/show_location_map.dart';
import 'package:event_ease/views/bottom_nav_bar/bottom_navbar.dart';
import 'package:event_ease/views/chat_view/chat_screen.dart';
import 'package:event_ease/views/edit_profile_view/edit_profile_view.dart';
import 'package:event_ease/views/manage_banquet_view/manage_banquet_screen.dart';
import 'package:event_ease/views/my_bookings_view/owner_booking_view.dart';
import 'package:event_ease/views/notification_view/notification_view.dart';
import 'package:event_ease/views/splash_view/splash_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String splash = '/';
  static const String register = '/register';
  static const String bookerLogin = '/booker-login';
  static const String ownerLogin = '/owner-login';
  static const String navbar = '/navbar';
  static const String editProfile = '/edit-profile';
  static const String banquetDetailScreen = '/banquet-detail-screen';
  static const String showLocationMap = '/show-location-map';
  static const String bookingScreen = '/bookingScreen';
  static const String addBanquetScreen = '/add-banquet-screen';
  static const String manageBanquetScreen = '/manage-banquet-screen';
  static const String chatScreen = '/chat-screen';
  static const String ownerBookingsScreen = '/ownerBookingsScreen';
  static const String notificationScreen = '/notificationScreen';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: bookerLogin,
      page: () => BookerLogin(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: ownerLogin,
      page: () => OwnerLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: navbar,
      page: () {
        final role = Get.arguments['role'];
        return NavbarPage(role: role);
      },
    ),
    GetPage(
        name: banquetDetailScreen,
        page: () {
          final banquet = Get.arguments['banquet'];
          final hideButton = Get.arguments.containsKey('hideButton') ? Get.arguments['hideButton'] : false;
          return BanquetDetailScreen(banquet: banquet, hideButton: hideButton);
        }),
    GetPage(
        name: bookingScreen,
        page: () {
          final banquet = Get.arguments['banquet'];
          return BookingScreen(
            banquet: banquet,
          );
        }),
    GetPage(name: showLocationMap, page: () => const ShowLocationMap()),
    GetPage(name: editProfile, page: () => EditProfileScreen()),
    GetPage(name: ownerBookingsScreen, page: () => const OwnerBookingsScreen()),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),
    GetPage(
      name: addBanquetScreen,
      page: () => AddBanquetScreen(),
      binding: AddBanquetBinding(),
    ),
    GetPage(
      name: manageBanquetScreen,
      page: () => const ManageBanquetsScreen(),
    ),
    GetPage(
      name: chatScreen,
      page: () => ChatScreen(
        ownerId: Get.arguments['ownerId'],
        bookerId: Get.arguments['bookerId'],
        bookingId: Get.arguments['bookingId'],
      ),
    ),
  ];
}
