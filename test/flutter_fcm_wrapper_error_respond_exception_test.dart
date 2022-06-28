import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_respond_exception.dart';
import 'package:flutter_fcm_wrapper/flutter_fcm_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //Replace with your own API Key
  const FlutterFCMWrapper flutterFCMWrapper = FlutterFCMWrapper(
    apiKey: "Replace with your own user API key",
  );

  test('Topic Notification Server Error Respond Exception', () {
    //Invalid key provided, will cause authentication error
    const flutterFMCWithInvalidKey =
        FlutterFCMWrapper(apiKey: "Example Invalid Key");
    expect(flutterFMCWithInvalidKey.sendTopicMessage(topicName: "Test"),
        throwsA(isA<FlutterFCMWrapperRespondException>()));

    //"from" is a reserved keyword, so server will return error
    expect(
        flutterFCMWrapper
            .sendTopicMessage(topicName: "Test", data: {"from": "test"}),
        throwsA(isA<FlutterFCMWrapperRespondException>()));
  });

  test('Token Notification Server Error Respond Exception', () {
    //Invalid key provided, will cause authentication error
    const FlutterFCMWrapper flutterFCMWithInvalidKey =
        FlutterFCMWrapper(apiKey: "Example Invalid Key");
    expect(
        flutterFCMWithInvalidKey
            .sendMessageByTokenID(userRegistrationTokens: ["userToken"]),
        throwsA(isA<FlutterFCMWrapperRespondException>()));

    //"from" is a reserved keyword, so server will return error
    expect(
        flutterFCMWrapper.sendMessageByTokenID(
            userRegistrationTokens: ["userToken"], data: {"from": "test"}),
        throwsA(isA<FlutterFCMWrapperRespondException>()));
  });
}
