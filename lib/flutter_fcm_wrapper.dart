library flutter_fcm_wrapper;

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_invalid_data_exception.dart';
import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_respond_exception.dart';
import 'package:http/http.dart' as http;

const fcmEndPoint = "https://fcm.googleapis.com/fcm/send";
const contentType = "application/json";
const encodingName = "utf-8";

/// FCM API Wrapper for Flutter
class FlutterFCMWrapper {
  ///API Key obtained from firebase console
  ///
  /// Required to authenticate sender's identity
  final String _apiKey;

  ///Enable to log error thrown and message delivery status
  ///
  ///Set to false by default
  final bool enableLog;

  ///Enable to log raw header and body respond from the server
  ///
  ///Set to false by default
  final bool enableServerRespondLog;

  /// Constructs an instance of [FlutterFCMWrapper].
  const FlutterFCMWrapper(
      {required String apiKey,
      this.enableLog = false,
      this.enableServerRespondLog = false})
      : _apiKey = apiKey;

  ///Sends topic message
  ///
  ///Returns message id if message has been send successfully
  ///
  ///*Sample Respond*
  ///
  ///```json
  ///{
  ///  "message_id":6205640702260258345
  ///}
  ///```
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [topicName] and [condition] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [topicName] or [condition] is not provided
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [title] and [titleLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [body] and [bodyLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [isDataMessage] is set to true while other options
  ///is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if [badge] is lesser than 1
  ///
  ///[Ref Link]: https://firebase.google.com/docs/cloud-messaging/http-server-ref
  Future<String> sendTopicMessage({
    String? topicName,
    String? condition,
    String? title,
    String? body,
    String? titleLocKey,
    List<Map<String, String>>? titleLocArgs,
    String? bodyLocKey,
    List<Map<String, String>>? bodyLocArgs,
    String? subtitle,
    String? collapseKey,
    bool isHighPriority = true,
    bool? contentAvailable,
    Map<String, bool>? mutableContent,
    int? timeToLive,
    String? restrictedPackageName,
    bool isDryRun = false,
    Map<String, String>? data,
    String? sound,
    String? icon,
    String? tag,
    String? color,
    String? imageUrl,
    int? badge,
    String? clickAction,
    String? androidChannelID,
    bool isDataMessage = false,
  }) async {
    if (topicName == null && condition == null) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Either topic name or condition must be assigned");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage: "Either topic name or condition must be assigned"));
    }

    if (topicName != null && condition != null) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Topic name and condition cannot be assigned at the same time");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage:
              "Topic name and condition cannot be assigned at the same time"));
    }

    Map<String, dynamic> messageBodyPayLoad = {};

    if (condition == null) {
      messageBodyPayLoad["to"] = "/topics/$topicName";
    } else {
      messageBodyPayLoad["condition"] = condition;
    }

    messageBodyPayLoad.addAll(_generateRequestBody(
        collapseKey: collapseKey,
        isHighPriority: isHighPriority,
        contentAvailable: contentAvailable,
        mutableContent: mutableContent,
        timeToLive: timeToLive,
        restrictedPackageName: restrictedPackageName,
        isDryRun: isDryRun,
        data: data));

    //Build Notification Payload
    Map<String, dynamic> notificationPayLoad = _generateMessagePayload(
        title: title,
        body: body,
        subtitle: subtitle,
        sound: sound,
        icon: icon,
        tag: tag,
        color: color,
        imageUrl: imageUrl,
        badge: badge,
        clickAction: clickAction,
        bodyLocKey: bodyLocKey,
        bodyLocArgs: bodyLocArgs,
        titleLocKey: titleLocKey,
        titleLocArgs: titleLocArgs,
        androidChannelID: androidChannelID,
        isDataMessage: isDataMessage);

    //notificationPayLoad is not being included so no default sound will be played
    if (!isDataMessage) {
      messageBodyPayLoad["notification"] = notificationPayLoad;
    }

    //Send request to server
    http.Response response =
        await _sendRequest(payLoadBody: messageBodyPayLoad);

    try {
      //Phrase respond to readable format
      return _phraseRespond(response: response)["message_id"].toString();
    } on FlutterFCMWrapperRespondException {
      rethrow;
    }
  }

  ///Sends topic message
  ///
  ///Returns message token if message has been send successfully
  ///
  ///*Sample Respond*
  ///
  ///```json
  ///{
  ///   Message Token: {
  ///         multicast_id: -1,
  ///         success: 1,
  ///         failure: 1,
  ///         canonical_ids: 0,
  ///         results: [
  ///             {error: InvalidRegistration},
  ///             {message_id: fake_message_id}
  ///         ]
  ///     }
  ///}
  ///```
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [userRegistrationTokens] is empty
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [userRegistrationTokens] length is more than 1000
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [title] and [titleLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [body] and [bodyLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [isDataMessage] is set to true while other options
  ///is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if [badge] is lesser than 1
  ///
  ///[Ref link]: https://firebase.google.com/docs/cloud-messaging/http-server-ref
  Future<Map<String, dynamic>> sendMessageByTokenID({
    required List<String> userRegistrationTokens,
    String? title,
    String? body,
    String? subtitle,
    String? titleLocKey,
    List<Map<String, String>>? titleLocArgs,
    String? bodyLocKey,
    List<Map<String, String>>? bodyLocArgs,
    String? collapseKey,
    bool isHighPriority = true,
    bool? contentAvailable,
    Map<String, bool>? mutableContent,
    int? timeToLive,
    String? restrictedPackageName,
    bool isDryRun = false,
    Map<String, String>? data,
    String? sound,
    String? icon,
    String? tag,
    String? color,
    String? imageUrl,
    int? badge,
    String? clickAction,
    String? androidChannelID,
    bool isDataMessage = false,
  }) async {
    //At least 1 registration token should be provided
    if (userRegistrationTokens.isEmpty) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: At least 1 registration token should be provided");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage: "At least 1 registration token should be provided"));
    }

    //A limit of 1000 tokens can be delivered each time
    if (userRegistrationTokens.length > 1000) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: A limit of 1000 tokens can be delivered each time");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage: "A limit of 1000 tokens can be delivered each time"));
    }

    Map<String, dynamic> notificationBodyPayLoad = {};

    if (userRegistrationTokens.length == 1) {
      notificationBodyPayLoad["to"] = userRegistrationTokens.first;
    } else {
      notificationBodyPayLoad["registration_ids"] = userRegistrationTokens;
    }

    notificationBodyPayLoad.addAll(_generateRequestBody(
        collapseKey: collapseKey,
        isHighPriority: isHighPriority,
        contentAvailable: contentAvailable,
        mutableContent: mutableContent,
        timeToLive: timeToLive,
        restrictedPackageName: restrictedPackageName,
        isDryRun: isDryRun,
        data: data));

    //Build Notification Payload
    Map<String, dynamic> notificationPayLoad = _generateMessagePayload(
        title: title,
        body: body,
        subtitle: subtitle,
        sound: sound,
        icon: icon,
        tag: tag,
        color: color,
        imageUrl: imageUrl,
        badge: badge,
        clickAction: clickAction,
        bodyLocKey: bodyLocKey,
        bodyLocArgs: bodyLocArgs,
        titleLocKey: titleLocKey,
        titleLocArgs: titleLocArgs,
        androidChannelID: androidChannelID,
        isDataMessage: isDataMessage);

    if (!isDataMessage) {
      notificationBodyPayLoad["notification"] = notificationPayLoad;
    }

    http.Response response =
        await _sendRequest(payLoadBody: notificationBodyPayLoad);

    try {
      return _phraseRespond(response: response);
    } on FlutterFCMWrapperRespondException {
      rethrow;
    }
  }

  ///Construct request body
  Map<String, dynamic> _generateRequestBody({
    String? collapseKey,
    bool isHighPriority = true,
    bool? contentAvailable,
    Map<String, bool>? mutableContent,
    int? timeToLive,
    String? restrictedPackageName,
    bool isDryRun = false,
    Map<String, String>? data,
  }) {
    Map<String, dynamic> notificationBasePayLoad = {};
    if (collapseKey != null) {
      notificationBasePayLoad["collapse_key"] = collapseKey;
    }

    if (isHighPriority) {
      notificationBasePayLoad["priority"] = "high";
    } else {
      notificationBasePayLoad["priority"] = "normal";
    }

    if (contentAvailable != null) {
      notificationBasePayLoad["content_available"] = contentAvailable;
    }

    if (mutableContent != null) {
      notificationBasePayLoad["mutable_content"] = mutableContent;
    }

    if (timeToLive != null) {
      notificationBasePayLoad["time_to_live"] = timeToLive;
    }

    if (restrictedPackageName != null) {
      notificationBasePayLoad["restricted_package_name"] =
          restrictedPackageName;
    }

    if (isDryRun) {
      notificationBasePayLoad["dry_run"] = isDryRun;
    }

    if (data != null) {
      notificationBasePayLoad["data"] = data;
    }

    return notificationBasePayLoad;
  }

  ///Send request to FCM Server
  Future<http.Response> _sendRequest(
      {required Map<String, dynamic> payLoadBody}) async {
    if (enableLog) {
      log("Flutter FCM Wrapper: Sending Request to FCM Server");
    }

    return await http.post(Uri.parse(fcmEndPoint),
        body: json.encode(payLoadBody),
        encoding: Encoding.getByName(encodingName),
        headers: _generateHeader());
  }

  ///Construct message payload
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [title] and [titleLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [body] and [bodyLocArgs] is provided at the same time
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if [badge] is lesser than 1
  ///
  ///Throws an [FlutterFCMWrapperInvalidDataException] if option [isDataMessage] is set to true while other options
  ///is provided at the same time
  Map<String, dynamic> _generateMessagePayload({
    String? title,
    String? body,
    String? titleLocKey,
    List<Map<String, String>>? titleLocArgs,
    String? bodyLocKey,
    List<Map<String, String>>? bodyLocArgs,
    String? subtitle,
    String? sound,
    String? icon,
    String? tag,
    String? color,
    String? imageUrl,
    int? badge,
    String? clickAction,
    String? androidChannelID,
    bool isDataMessage = false,
  }) {
    if (title != null && titleLocArgs != null) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Both title or titleLocKey cannot be assigned at the same time");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage:
              "Both title or titleLocKey cannot be assigned at the same time"));
    }

    if (body != null && bodyLocArgs != null) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Both body or bodyLocKey cannot be assigned at the same time");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage:
              "Both body or bodyLocKey cannot be assigned at the same time"));
    }

    Map<String, dynamic> notification = {};

    if (imageUrl != null) {
      notification['image'] = imageUrl;
    }

    if (title != null) {
      notification["title"] = title;
    }

    if (titleLocKey != null) {
      notification["title_loc_key"] = titleLocKey;
    }

    if (titleLocArgs != null) {
      notification["title_loc_args"] = titleLocArgs;
    }

    if (body != null) {
      notification["body"] = body;
    }

    if (bodyLocKey != null) {
      notification["body_loc_key"] = bodyLocKey;
    }

    if (bodyLocArgs != null) {
      notification["body_loc_args"] = bodyLocArgs;
    }

    if (subtitle != null) {
      notification["subtitle"] = subtitle;
    }

    if (clickAction != null) {
      notification["click_action"] = subtitle;
    }

    if (sound != null) {
      notification["sound"] = sound;
    }

    //Build Android Config
    if (androidChannelID != null) {
      notification["android_channel_id"] = androidChannelID;
    }

    if (icon != null) {
      notification["icon"] = icon;
    }

    if (tag != null) {
      notification["tag"] = tag;
    }

    if (color != null) {
      notification["color"] = color;
    }

    //Build apns Config
    if (badge != null) {
      if (badge < 0) {
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Badge value cannot be lower than 1");
        }
        throw (const FlutterFCMWrapperInvalidDataException(
            errorMessage: "Badge value cannot be lower than 1"));
      }
      notification["badge"] = badge;
    }

    if (notification.isNotEmpty && isDataMessage) {
      if (enableLog) {
        log("Flutter FCM Wrapper [FlutterFCMWrapperInvalidDataException] Exception: Data message is set to true but notification's parameter is provided at the same time");
      }
      throw (const FlutterFCMWrapperInvalidDataException(
          errorMessage:
              "Data message is set to true but notification's parameter is provided at the same time"));
    }

    return notification;
  }

  ///Generate request header
  Map<String, String> _generateHeader() {
    return {'content-type': contentType, 'Authorization': "key=$_apiKey"};
  }

  ///Format the respond by server
  Map<String, dynamic> _phraseRespond({required http.Response response}) {
    if (enableServerRespondLog) {
      log("Flutter FCM Wrapper Raw Server Respond Headers: ${response.headers.toString()}");
      log("Flutter FCM Wrapper Raw Server Respond Body: ${response.body.toString()}");
    }
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (enableLog) {
          if (data.length == 1) {
            log("Flutter FCM Wrapper Topic Message Send Successfully\n-Message Token: ${data["message_id"]}");
          } else {
            log("Flutter FCM Wrapper Token Message Send Successfully\n-Message Token: $data");
          }
        }

        return data;

      case 400:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: ${response.body}");
        }
        throw FlutterFCMWrapperRespondException(errorMessage: response.body);

      case 401:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Authentication error, invalid key might be provided");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage:
                "Authentication error, invalid key might be provided");
      case 403:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Sender ID does not match with token");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Sender ID does not match with token");

      case 404:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Token has not been registered");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Token has not been registered");

      case 429:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Quota exceeded please try again later");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Quota exceeded please try again later");

      case 500:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Unknown internal error");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Unknown internal error");

      case 503:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Server overload please try again later");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Server overload please try again later");

      default:
        if (enableLog) {
          log("Flutter FCM Wrapper [FlutterFCMWrapperRespondException] Exception: Unknown error");
        }
        throw const FlutterFCMWrapperRespondException(
            errorMessage: "Unknown error");
    }
  }
}
