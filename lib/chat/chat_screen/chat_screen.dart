import 'package:famewall/PrefUtils.dart';
import 'package:famewall/chat/chat_screen/provider/chat_screen_provider.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_app_bar.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_input.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isFirstTime = false;
  late String peerId;
  late String peerName;
  late String profileImage;
  late String userId;
  late String userName;
  late String userProfileImage;
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();
  final textFieldFocusNode = FocusNode();

  void getArguments() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    peerId = arguments['peerId'];
    peerName = arguments['peerName'];
    profileImage = arguments['profileImage'];
    Provider.of<ChatScreenProvider>(context, listen: false)
        .setPeerDetails(peerName, peerId, profileImage);
  }

  void updateUserDetails() {
    userId = PreferenceUtils.getString("userId", "");
    userName = PreferenceUtils.getString("userName", "");
    userProfileImage = PreferenceUtils.getString("userProfileImage", "");
    Provider.of<ChatScreenProvider>(context, listen: false)
        .setUserDetails(userName, userId, userProfileImage);
  }

  @override
  Widget build(BuildContext context) {
    if (!isFirstTime) {
      isFirstTime = true;
      getArguments();
      updateUserDetails();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ChatAppBar(profileImage: profileImage, peerName: peerName),
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 1.0),
                              blurRadius: 1.0,
                            ),
                          ],
                        ),
                        child: const ChatList(),
                      ),
                    ),
                  ),
                  const ChatInput(),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(top: 10),
          //   child: Container(
          //     padding: const EdgeInsets.all(5),
          //     height: 30,
          //     width: 30,
          //     decoration: const BoxDecoration(
          //       shape: BoxShape.circle,
          //     ),
          //     child: const CircularProgressIndicator(
          //       strokeWidth: 2.0,
          //       valueColor: AlwaysStoppedAnimation<Color>(
          //         Colors.grey,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
