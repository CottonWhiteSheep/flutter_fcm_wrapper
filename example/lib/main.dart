import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_invalid_data_exception.dart';
import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_respond_exception.dart';
import 'package:flutter_fcm_wrapper/flutter_fcm_wrapper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Run when message ies being received in the background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

//Use to show notification
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize firebase
  //TODO:: Set up your own firebase, then import the missing library
  await Firebase.initializeApp(options: FirebaseOptions.currentPlatform);
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  //Obtain user notification token
  String? token = await firebaseMessaging.getToken();

  //Subscribe to firebase topic
  await firebaseMessaging.subscribeToTopic("example");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (Platform.isAndroid) {
    //Create android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'example', // id
          "Example", // title
          importance: Importance
              .max, //Set the importance to the highest so the notification will be shown immediately
        ));
  }

  if (Platform.isIOS) {
    //Request for notification permission on iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  //Declare the notification's icon
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  //iOS Uses the default setting
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();

  //Initialize the settings
  _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS),
      onSelectNotification: _notificationSelectedAction);

  //Listen to message received
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //Notification details received
    RemoteNotification? notification = message.notification;
    AndroidNotificationDetails? androidPlatformChannelSpecifics;
    IOSNotificationDetails? iosDetails;
    if (Platform.isAndroid) {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'example', "Example",
          importance: Importance.max, priority: Priority.high, showWhen: false);
    }

    if (Platform.isIOS) {
      iosDetails = const IOSNotificationDetails(
        presentSound: true,
        presentAlert: true,
      );
    }

    //Show the notification
    _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iosDetails),
    );
  });

  runApp(MyApp(
    token: token,
  ));
}

//Action run when notification clicked on
Future _notificationSelectedAction(String? payload) async {
  return Builder(builder: (BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const MyApp()),
    );
    return Container();
  });
}

class MyApp extends StatefulWidget {
  final String? token;

  const MyApp({Key? key, this.token}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Wrapper Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(token: widget.token),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? token;

  const MyHomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //TODO::Insert your own API key
  FlutterFCMWrapper flutterFCMWrapper = const FlutterFCMWrapper(
    apiKey: "Your own api key here",
    enableLog: true,
    enableServerRespondLog: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter FCM Wrapper Example"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => _sendTopicMessage(),
                child: const Text("Send Topic Message")),

            //Button hide if failed to obtain user's token
            Visibility(
                visible: widget.token != null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _sendTokenMessage(),
                    child: const Text("Send Token Message"),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void _sendTopicMessage() async {
    try {
      String result = await flutterFCMWrapper.sendTopicMessage(
          topicName: "example",
          title: "Example",
          body: "Topic message send using Flutter FCM Wrapper",
          androidChannelID: "example",
          clickAction: "FLUTTER_NOTIFICATION_CLICK");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Topic Message ID: $result")));
    } on FlutterFCMWrapperInvalidDataException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Topic Message Error: ${e.toString()}")));
    } on FlutterFCMWrapperRespondException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Topic Message Error: ${e.toString()}")));
    }
  }

  void _sendTokenMessage() async {
    try {
      Map<String, dynamic> result = await flutterFCMWrapper
          .sendMessageByTokenID(
              userRegistrationTokens: [widget.token!],
              title: "Example",
              body: "Token message send using Flutter FCM Wrapper",
              androidChannelID: "example",
              clickAction: "FLUTTER_NOTIFICATION_CLICK");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Token Message ID: ${(result["results"] as List<dynamic>).first["message_id"]}")));
    } on FlutterFCMWrapperInvalidDataException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token Message Error: ${e.toString()}")));
    } on FlutterFCMWrapperRespondException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token Message Error: ${e.toString()}")));
    }
  }
}
