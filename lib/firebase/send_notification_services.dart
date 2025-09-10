import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/advertising-app-597a6-63a5da261d27.json',
  );

  final accountCredentials = auth.ServiceAccountCredentials.fromJson(
    jsonString,
  );

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  try {
    final String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/advertising-app-597a6/messages:send';

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data,
          'android': {
            'notification': {
              "sound": "custom_sound",
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'channel_id': 'high_importance_channel',
            },
          },
          'apns': {
            'payload': {
              'aps': {"sound": "custom_sound.caf", 'content-available': 1},
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print(
        '✅ Notification sent successfully to token: ${token.substring(0, 20)}...',
      );
    } else {
      // ignore: avoid_print
      print('❌ Failed to send notification: ${response.body}');
    }
  } catch (e) {
    // ignore: avoid_print
    print('❌ Error sending notification: $e');
  }
}
