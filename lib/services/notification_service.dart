
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitialization =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // const IOSInitializationSettings iosInitialization =
    //     IOSInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialization,
      // iOS: iosInitialization,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Show local notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel', // Channel ID
        'Main Channel', // Channel Name
        channelDescription: 'Main notification channel',
        importance: Importance.high,
        priority: Priority.high,
      ),
      // iOS: IOSNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
