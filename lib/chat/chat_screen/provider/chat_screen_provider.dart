import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/PrefUtils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ChatScreenProvider extends ChangeNotifier {
  String serverKey =
      "AAAAx1wbmxY:APA91bH7l5medwL6oY8qsbWKFWuVWuSk9RKS0ZgTz-7tkkPn_vEeYf1mlN2VukZZZ7Z4hPQxg3lDJWICYxpPvF-YvIb5jdVIJQOCPxf3ZUfhMypuDx5anjCjBwPD6D30sgvGnM_McfgO";
  final List<dynamic> _chatItems = [];
  bool _isLoading = false;
  String? userId;
  String? userName;
  String? userProfile;
  String? peerId;
  String? peerName;
  String? peerProfileImage;
  String? groupChatId;
  File? image;
  int limit = 20;

  ChatScreenProvider() {
    userId = PreferenceUtils.getString("userId", "");
    userName = PreferenceUtils.getString("userName", "");
  }

  void setPeerDetails(String name, String id, String profileImage) {
    peerId = id;
    peerName = name;
    peerProfileImage = profileImage;
  }

  void setUserDetails(String name, String id, String profileImage) {
    userId = id;
    userName = name;
    profileImage = profileImage;
    if (userId.hashCode <= peerId.hashCode) {
      groupChatId = '$userId-$peerId';
    } else {
      groupChatId = '$peerId-$userId';
    }
  }

  UnmodifiableListView<dynamic> get chatItems =>
      UnmodifiableListView(_chatItems);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    int badgeCount = 0;

    if (groupChatId?.isNotEmpty ?? false) {
      try {
        var documentReference = FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId!)
            .doc(DateTime.now().millisecondsSinceEpoch.toString());
        await FirebaseFirestore.instance.runTransaction(
          (transaction) async {
            transaction.set(
              documentReference,
              {
                'idFrom': userId,
                'idTo': peerId,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                'content': content,
                'type': type
              },
            );
          },
        );
        await FirebaseFirestore.instance
            .collection("chatList")
            .doc(userId)
            .collection(userId!)
            .doc(peerId)
            .set({
          'id': peerId,
          'name': peerName,
          'badge': 0,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'profileImage': peerProfileImage,
          'type': type
        });
        await FirebaseFirestore.instance
            .collection("chatList")
            .doc(peerId)
            .collection(peerId!)
            .doc(userId)
            .get()
            .then((doc) async {
          if (doc.data() != null &&
              (doc.data() as Map<String, dynamic>)["badge"] != null) {
            badgeCount = (doc.data() as Map<String, dynamic>)["badge"];
          } else {
            badgeCount = 0;
          }
          await FirebaseFirestore.instance
              .collection("chatList")
              .doc(peerId)
              .collection(peerId!)
              .doc(userId)
              .set({
            'id': userId,
            'name': userName,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'badge': badgeCount + 1,
            'profileImage': userProfile,
            'type': type
          });
        });
        FirebaseFirestore.instance
            .collection('user')
            .doc(peerId)
            .get()
            .then((peerData) {
          if (peerData.exists) {
            if (type == 0) {
              sendNotification(peerData['token'], content);
            } else {
              sendImageNotification(peerData['token'], content);
            }
          }
        });
      } catch (e) {
        // await FirebaseFirestore.instance
        //     .collection("chatList")
        //     .doc(peerId)
        //     .collection(peerId!)
        //     .doc(userId)
        //     .set({
        //   'id': userId,
        //   'name': userName,
        //   'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        //   'content': content,
        //   'badge': '${badgeCount + 1}',
        //   'profileImage': userProfile,
        //   'type': type
        // });
        debugPrint(e.toString());
      }
    }
  }

  Future<http.Response> sendNotification(
      String peerToken, String content) async {
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

  Future<UploadTask> uploadFile(File file) async {
    UploadTask uploadTask;
    var timeKey = DateTime.now();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profileImage')
        .child('/$timeKey.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );
    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }
    image = File(imageFile.path);
    _isLoading = true;
    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path +
        "/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
    final compressed = await FlutterImageCompress.compressAndGetFile(
      image!.absolute.path,
      targetPath,
      quality: 20,
    );
    UploadTask task = await uploadFile(compressed!);
    TaskSnapshot storageTaskSnapshot = await task;
    try {
      final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      _isLoading = false;
      sendMessage(downloadUrl, 1);
    } catch (e) {
      debugPrint(e.toString());
      _isLoading = false;
    }
  }

  Future<void> resetBadgeCount() async {
    await FirebaseFirestore.instance
        .collection("chatList")
        .doc(userId)
        .collection(userId!)
        .doc(peerId)
        .update({'badge': 0});
  }
}
