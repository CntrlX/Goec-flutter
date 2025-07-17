import 'dart:io';
import 'dart:convert';
import '../constants.dart';
import 'package:get/get.dart';
import '../Singletones/app_data.dart';
import '../Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/routes.dart';
import '../Controller/charging_screen_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FireBaseNotification {
  //make it singleTone class
  static final FireBaseNotification _singleton =
      FireBaseNotification._internal();
  factory FireBaseNotification() {
    return _singleton;
  }

  init() async {
    await requestPermission();
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initSetttings,
      onDidReceiveNotificationResponse: localNotificationsClick,
    );
    loadFCM();
    subscribeToTopic();
    listenFCM();
    updateUserToken();
  }

  FireBaseNotification._internal();
  //code starts from here

  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  var channel;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      kLog('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      kLog('User granted provisional permission');
    } else {
      kLog('User declined or has not accepted permission');
    }
  }

  void loadFCM() async {
    channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is very important and primary channel for notifications',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('default'));

    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void listenFCM() async {
    /*  *********** When the app is open *********** */
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      logger.e(message.data);
      if (message.data['startCharge'] == 'true') {
        ChargingScreenController _chargingController =
            await Get.put(ChargingScreenController());
        await _chargingController.getChargingStatus();
      } else {
        appData.notificationAvailable.value = true;
        RemoteNotification? notification = message.notification;
        // Make te notification red tilt true
        if (notification != null) {
          if (Platform.isAndroid)
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id, channel.name,
                  icon: 'logo',
                  playSound: false,
                  fullScreenIntent: false,
                  ongoing: false,
                  styleInformation: BigTextStyleInformation(''),
                  // sound: RawResourceAndroidNotificationSound('eshogol_tone'),
                  // sound: RawResourceAndroidNotificationSound('notification'),
                ),
              ),
              payload: jsonEncode(message.data),
            );
        }
      }
    });
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        openPage(message);
      }
    });
    //When the app is completely closed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        openPage(message);
      }
    });
  }

  subscribeToTopic() {
    _fcm.subscribeToTopic('general');
  }

  static openPage(RemoteMessage message) {
    Get.toNamed(Routes.notificationPageRoute);
  }

  static localNotificationsClick(NotificationResponse response) {
    // Handle notification click
  }

  unsubscribeFirebaseNotification() {
    _fcm.deleteToken();
    _fcm.unsubscribeFromTopic('general');
  }

  //Save notification id to server
  updateUserToken() async {
    if (appData.token.isNotEmpty) {
      var token = await _fcm.getToken();
      await CommonFunctions().updateFcmToken(token: token ?? '');
    }
  }
}
