import 'package:flutter_fcm_wrapper/exception/flutter_fcm_wrapper_invalid_data_exception.dart';
import 'package:flutter_fcm_wrapper/flutter_fcm_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //Replace with your own API Key
  const FlutterFCMWrapper flutterFCM = FlutterFCMWrapper(
    apiKey: "Replace with your own user API key",
  );

  test('Topic Notification Invalid Data Exception', () {
    //No topic is provided
    expect(flutterFCM.sendTopicMessage(),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Both topic and condition is being provided
    expect(flutterFCM.sendTopicMessage(topicName: "test", condition: "test1"),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Both title and titleLocArgs is provided
    expect(
        flutterFCM.sendTopicMessage(
            topicName: "test",
            title: "test",
            titleLocArgs: [
              {"CN": "测试"}
            ],
            isDryRun: true),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Both body and bodyLocArgs is provided
    expect(
        flutterFCM
            .sendTopicMessage(topicName: "test", body: "test", bodyLocArgs: [
          {"CN": "测试"}
        ]),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Notification is set as data message, but notification parameters is provided
    expect(
        flutterFCM.sendTopicMessage(
            topicName: "test", title: "test", isDataMessage: true),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));
  });

  test('Token Notification Invalid Data Exception', () {
    //No token is provided
    expect(flutterFCM.sendMessageByTokenID(userRegistrationTokens: []),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //More than 1000 token is provided
    List<String> sampleTokens = List.generate(1001, (index) => "");

    expect(
        flutterFCM.sendMessageByTokenID(userRegistrationTokens: sampleTokens),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Both title and titleLocArgs is provided
    expect(
        flutterFCM.sendMessageByTokenID(
            userRegistrationTokens: ["sampleToken"],
            title: "test",
            titleLocArgs: [
              {"CN": "测试"}
            ],
            isDryRun: true),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Both body and bodyLocArgs is provided
    expect(
        flutterFCM.sendMessageByTokenID(
            userRegistrationTokens: ["sampleToken"],
            body: "test",
            bodyLocArgs: [
              {"CN": "测试"}
            ]),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));

    //Notification is set as data message, but notification parameters is provided
    expect(
        flutterFCM.sendMessageByTokenID(
            userRegistrationTokens: ["sampleToken"],
            title: "test",
            isDataMessage: true),
        throwsA(isA<FlutterFCMWrapperInvalidDataException>()));
  });
}
