import 'package:flutter_fcm_wrapper/flutter_fcm_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  //Replace with your own API Key
  const flutterFCMWrapper = FlutterFCMWrapper(
    apiKey: "Replace with your own user API key",
  );

  test('Topic Notification Invalid Data Exception', () async {
    //Expected -1 since its a dry run
    expect(
        await flutterFCMWrapper.sendTopicMessage(
            topicName: "test", isDryRun: true, isDataMessage: true),
        "-1");

    //Check return type since message ID is generated randomly
    expect(
        (await flutterFCMWrapper.sendTopicMessage(
                topicName: "test", isDataMessage: true))
            .runtimeType,
        String);
  });

  test('Token Notification Invalid Data Exception', () async {
    //Replace with your own user token
    String userToken = "Replace with your own user token";

    //Expected 0 since the provided user token is valid
    expect(
        (await flutterFCMWrapper.sendMessageByTokenID(
            userRegistrationTokens: [userToken],
            isDataMessage: true,
            isDryRun: true))["failure"],
        0);

    //Expected 1 since the provided user token is invalid
    expect(
        (await flutterFCMWrapper.sendMessageByTokenID(
            userRegistrationTokens: ["fakeUserToken"],
            isDataMessage: true,
            isDryRun: true))["failure"],
        1);

    //Expected 1 since one of the provided user token is invalid
    expect(
        (await flutterFCMWrapper.sendMessageByTokenID(
            userRegistrationTokens: ["fakeUserToken", userToken],
            isDataMessage: true,
            isDryRun: true))["failure"],
        1);
  });
}
