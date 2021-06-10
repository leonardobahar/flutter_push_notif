import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'PushNotification.dart';
import 'notification_badge.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  late LocalPushNotification _notificationInfo;

  @override
  void initState() {
    _totalNotifications = 0;
    super.initState();
    registerNotification();
  }

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // 4. Check permission, if user granted permission, perform notification handling
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        LocalPushNotification notification = LocalPushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        print('Received title ' + notification.title!);
        print('Received body ' + notification.body!);

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        // For displaying the notification as an overlay
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notify'),
        brightness: Brightness.dark,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          SizedBox(height: 16.0),
          ElevatedButton(
              onPressed: () {
                AwesomeNotifications().createNotification(
                    content: NotificationContent(
                        id: 10,
                        channelKey: 'basic_channel',
                        title: 'Simple Notification',
                        body: 'Simple body'));
              },
              child: Text('Notify'))
          // TODO: add the notification text here
        ],
      ),
    );
  }
}
