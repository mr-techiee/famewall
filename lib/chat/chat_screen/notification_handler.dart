import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/PrefUtils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


String serverKey =
    "AAAAx1wbmxY:APA91bH7l5medwL6oY8qsbWKFWuVWuSk9RKS0ZgTz-7tkkPn_vEeYf1mlN2VukZZZ7Z4hPQxg3lDJWICYxpPvF-YvIb5jdVIJQOCPxf3ZUfhMypuDx5anjCjBwPD6D30sgvGnM_McfgO";

setNotificationData(
    String peerId, String type, String message, String redirectId) {
  final time = DateTime.now().millisecondsSinceEpoch.toString();
  final userId = PreferenceUtils.getString("userId", "");
  FirebaseFirestore.instance.collection("notification").doc(time).set({
    "idFrom": userId,
    "idTo": peerId,
    "type": type,
    "message": message,
    "timestamp": time,
    "redirectId": redirectId
  }).then((value) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(peerId)
        .get()
        .then((peerData) {
      if (peerData.exists) {
        sendNotification(peerData['token'], message);
      }
    });
  });
}

Future<http.Response> sendNotification(String peerToken, String content) async {
  final userId = PreferenceUtils.getString("userId", "");
  final userName = PreferenceUtils.getString("userName", "");
  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "key=$serverKey"
    },
    body: jsonEncode({
      "to": peerToken,
      "priority": "high",
      "data": {
        "type": "100",
        "user_id": userId,
        "title": content,
        "message": userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "sound": "default",
        "vibrate": "300",
      },
      "notification": {
        "vibrate": "300",
        "priority": "high",
        "body": content,
        "title": userName,
        "sound": "default",
      }
    }),
  );
  return response;
}

Future<http.Response> sendImageNotification(
    String peerToken, String content) async {
  final userId = PreferenceUtils.getString("userId", "");
  final userName = PreferenceUtils.getString("userName", "");
  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "key=$serverKey"
    },
    body: jsonEncode({
      "to": peerToken,
      "priority": "high",
      "data": {
        "type": "100",
        "user_id": userId,
        "title": content,
        "message": userName,
        "image": content,
        "time": DateTime.now().millisecondsSinceEpoch,
        "sound": "default",
        "vibrate": "300",
      },
      "notification": {
        "vibrate": "300",
        "priority": "high",
        "body": "📷 Image",
        "title": userName,
        "sound": "default",
        "image": content,
      }
    }),
  );
  return response;
}
