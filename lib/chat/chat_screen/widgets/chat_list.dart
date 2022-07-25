import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/chat/chat_screen/provider/chat_screen_provider.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  late ChatScreenProvider provider;
  String? userId;
  int limit = 20;
  final listScrollController = ScrollController();

  bool isLastMessageRight(int index, List<QueryDocumentSnapshot> documents, String? userId) {
    return (
      (
        index > 0 && documents != null && documents[index - 1]['idFrom'] != userId
      ) || index == 0
    );
  }

  bool isLastMessageLeft(int index, List<QueryDocumentSnapshot> documents, String? userId) {
    return (
      (
        index > 0 && documents != null && documents[index - 1]['idFrom'] == userId
      ) || index == 0);
  }

  void _scrollListener() {
    if (listScrollController.position.pixels ==
        listScrollController.position.maxScrollExtent) {
      setState(() {
        limit = limit + 20;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ChatScreenProvider>(context, listen: false);
    userId = provider.userId;
    listScrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {    
    provider.resetBadgeCount();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    listScrollController.dispose();
  }  

  @override
  Widget build(BuildContext context) {       
    return Consumer<ChatScreenProvider>(builder: (context, store, child) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(store.groupChatId)
            .collection(store.groupChatId!)
            .orderBy('timestamp', descending: true)
            .limit(limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, index) => ChatMessage(
              index: index,
              document: (snapshot.data! as QuerySnapshot).docs[index],
              isLastMessageRight: isLastMessageRight(index, (snapshot.data! as QuerySnapshot).docs, userId),
              isLastMessageLeft: isLastMessageLeft(index, (snapshot.data! as QuerySnapshot).docs, userId),
              userId: userId ?? "",
            ),
            itemCount: (snapshot.data! as QuerySnapshot).docs.length,
            reverse: true,
            controller: listScrollController,
          );
        },
      );
    });
  }
}
