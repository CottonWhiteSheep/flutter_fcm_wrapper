[![GitHub License](https://img.shields.io/github/license/CottonWhiteSheep/flutter_fcm_wrapper)](https://github.com/CottonWhiteSheep/flutter_fcm_wrapper/blob/master/LICENSE) [![Pub Package](https://img.shields.io/pub/v/flutter_fcm_wrapper?color=0b7cbd&logo=Dart)](https://pub.dev/packages/flutter_fcm_wrapper)
# Flutter FCM Wrapper

A wrapper package for FCM REST API inspired by [PyFCM](https://github.com/olucurious/pyfcm)

## 🧭 Getting started

### ➕ Installation

Add Flutter FCM Wrapper to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_fcm_wrapper: <latest_version>
```

### 🔑 API Token

Get your API key from your [Firebase Console](https://console.firebase.google.com/u/0/)

1. Go to your Firebase Project
2. Go to project setting
3. Go to cloud messaging
4. Obtain your server key

### 🍎 iOS Set Up

If you are sending message to Apple client app you will need to add your APNS key to your
Firebase. Read more
at [Set up a Firebase Cloud Messaging client app on Apple platforms](https://firebase.google.com/docs/cloud-messaging/ios/client)

## 📤 Usage

### 🚧 Construct Flutter FCM Wrapper instance
```dart
import 'package:flutter_fcm_wrapper/flutter_fcm_wrapper.dart';

FlutterFCMWrapper flutterFCMWrapper = const FlutterFCMWrapper(
  apiKey: "Your Own API Key",
  enableLog: true,
  enableServerRespondLog: true,
);
```

### 📄 Sending Topic Message
```dart
String result = await flutterFCMWrapper.sendTopicMessage(
    topicName: "example",
    title: "Example",
    body: "Topic message send using Flutter FCM Wrapper",
    androidChannelID: "example",
    clickAction: "FLUTTER_NOTIFICATION_CLICK"
);
```

### 🪙 Sending Token Message
```dart
Map<String, dynamic> result = await
  flutterFCMWrapper.sendMessageByTokenID(userRegistrationTokens: [user's token],
  title: "Example",
  body: "Token message send using Flutter FCM Wrapper",
  androidChannelID: "example",
  clickAction: "FLUTTER_NOTIFICATION_CLICK"
);
```

### 🪝 Catching Exception
```dart
try {
    String result = await flutterFCMWrapper.sendTopicMessage(
        topicName: "example",
        title: "Example",
        body: "Topic message send using Flutter FCM Wrapper",
        androidChannelID: "example",
        clickAction: "FLUTTER_NOTIFICATION_CLICK"
    );
} on FlutterFCMWrapperInvalidDataException catch (e) {
//TODO:: Handle the error here
} on FlutterFCMWrapperRespondException catch (e) {
//TODO:: Handle the error here
}
```

## 📱 Example App

Example app includes other packages such
as [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
and [firebase_messaging,](https://pub.dev/packages/firebase_messaging) but it's not required as its being used to show
the notification on the device and also to obtain user's registration token.

User is also required to set up their [firebase](https://firebase.google.com/docs/flutter/setup) for their project and insert their own FCM API in order for the example app to run expectedly

## 📑 Reference

### 🔔 Flutter FCM Wrapper

|                        | Type     | Default Value | Nullable | Description                                                              |
|:-----------------------|:---------|:-------------:|:--------:|:-------------------------------------------------------------------------|
| apiKey                 | `String` |       -       |    ✅     | API Key obtained from firebase console to authenticate sender's identity |
| enableLog              | `bool`   |    `false`    |    ❌     | Enable to log error thrown and message delivery status                   |
| enableServerRespondLog | `bool`   |    `false`    |    ❌     | Enable to log raw header and body respond from the server                |

### 📄 Topic Message

|           | Type     | Default Value | Nullable | Description                                                                  |
|:----------|:---------|:-------------:|:--------:|:-----------------------------------------------------------------------------|
| topicName | `String` |       -       |    ✅     | The topic you wants to send this message to                                  |
| condition | `String` |       -       |    ✅     | Logic expression that determine which topic you want to send this message to |

#### ⚠️ Warning

1. FlutterFCMWrapperInvalidDataException will be thrown if topicName and condition **is being provided** at the same time
2. FlutterFCMWrapperInvalidDataException will be thrown if topicName and condition **is not being provided** at the same time

### 🪙 Token Message

|                        | Type           | Default Value | Nullable | Description                                                              |
|:-----------------------|:---------------|:-------------:|:--------:|:-------------------------------------------------------------------------|
| userRegistrationTokens | `List<String>` |       -       |    ❌     | List of user's registration tokens that you want to send this message to |

#### ⚠️ Warning

1. FlutterFCMWrapperInvalidDataException will be thrown if userRegistrationTokens is empty
2. FlutterFCMWrapperInvalidDataException will be thrown if userRegistrationTokens length is more than 1000

### 📝 Parameters

|                       | Type                        | Default Value | Nullable | Description                                                                                                        |
|:----------------------|:----------------------------|:-------------:|:--------:|:-------------------------------------------------------------------------------------------------------------------|
| title                 | `String`                    |       -       |    ✅     | Title of the notification                                                                                          |             
| body                  | `String`                    |       -       |    ✅     | Body of the notification                                                                                           |
| titleLocKey           | `String`                    |       -       |    ✅     | Key used to localize the title                                                                                     |             
| titleLocArgs          | `List<Map<String, String>>` |       -       |    ✅     | Used as format specifiers for the titleLocKey                                                                      |
| bodyLocKey            | `String`                    |       -       |    ✅     | Key used to localize the body                                                                                      |             
| bodyLocArgs           | `List<Map<String, String>>` |       -       |    ✅     | Used as format specifiers for the bodyLocKey                                                                       |            
| subtitle              | `String`                    |       -       |    ✅     | Subtitle of the notification                                                                                       |             
| collapseKey           | `String`                    |       -       |    ✅     | Used to group the notification                                                                                     |             
| isHighPriority        | `bool`                      |    `true`    |    ❌     | Priority of the notification                                                                                       |             
| contentAvailable      | `bool`                      |       -       |    ✅     | Application will be woken if set to true                                                                           |             
| mutableContent        | `Map<String,bool>`          |       -       |    ✅     | Ability to modify the notification's content before displaying it (Apple Platform only)                            |             
| timeToLive            | `int`                       |       -       |    ✅     | How long the message should be kept in the FCM storage when device is offline                                      |             
| restrictedPackageName | `String`                    |       -       |    ✅     | Register tokens must match with the provided package name in order to receive the notification(Android Only)       |             
| isDryRun              | `bool`                      |    `false`    |    ❌     | Used to send a test request without actually sending the notification                                              |             
| data                  | `Map<String,String>`        |       -       |    ✅     | Payload of the message                                                                                             |             
| sound                 | `String`                    |       -       |    ✅     | The sound to be play when the notification is received                                                             |             
| icon                  | `String`                    |       -       |    ✅     | Icon of the notification                                                                                           |
| tag                   | `String`                    |       -       |    ✅     | Use to replace the existing notification shown, if not specified new notification will be created for each request |
| color                 | `String`                    |       -       |    ✅     | The notification's icon color                                                                                      |
| imageUrl              | `String`                    |       -       |    ✅     | An Url which will be download and displayed on the notification                                                    |
| badge                 | `int`                       |       -       |    ✅     | Badge count for launchers                                                                                          |
| clickAction           | `String`                    |       -       |    ✅     | The action that happen when user click on the notification                                                         |
| androidChannelID      | `String`                    |       -       |    ✅     | Android notification's channel id                                                                                  |
| isDataMessage         | `bool`                      |    `false`    |    ❌     | If set to true, the notification send won't be shown or have any sound                                             |

#### ⚠️ Warning

1. FlutterFCMWrapperInvalidDataException will be thrown if title and titleLocKey is provided at the same time
2. FlutterFCMWrapperInvalidDataException will be thrown if body and bodyLocKey is provided at the same time
2. FlutterFCMWrapperInvalidDataException will be thrown if other parameters is provided and isDataMessage is set to true at the same time

### 😵 Exceptions

|                                       | Reason                                                      | Example Message                                     |
|:--------------------------------------|:------------------------------------------------------------|-----------------------------------------------------|
| FlutterFCMWrapperInvalidDataException | This error will be thrown if invalid parameters is provided | At least 1 registration token should be provided    |
| FlutterFCMWrapperRespondException     | This error will be thrown if server responds error          | Authentication error, invalid key might be provided |


### 🔗 Useful Links

For more detail explanation refer to [Parameters Documentation](https://firebase.google.com/docs/cloud-messaging/http-server-ref)

## 🤝 Contributing

Feel free to open new pull request for contributions.

If it is a major or breaking changes it is recommended to open it as an issue to discuss it.

## 🐛 Bugs

If any bugs has been found feel free to open an issue to discuss it.

## 📃 License

[MIT](https://github.com/CottonWhiteSheep/flutter_fcm_wrapper/blob/master/LICENSE)
