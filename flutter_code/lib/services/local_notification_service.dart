import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializeSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationPlugin.initialize(initializeSettings);
  }

  static void display(String title, String body) async {

    try {
      final id =  DateTime.now().millisecondsSinceEpoch ~/1000;
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "isdp",
          "idsp channel",
          importance: Importance.max,
          priority: Priority.high
        )
      );
      
      await _notificationPlugin.show(
          id,
          title,
          body,
          notificationDetails
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}