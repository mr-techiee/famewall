import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_post.dart';
import 'package:famewall/chat/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class ChatMessage extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final bool isLastMessageRight;
  final bool isLastMessageLeft;
  final String? userId;

  const ChatMessage({
    Key? key,
    required this.index,
    required this.document,
    required this.isLastMessageRight,
    required this.isLastMessageLeft,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (document['idFrom'] == userId) {
      return SelfMessage(
        document: document,
        isLastMessageRight: isLastMessageRight,
      );
    }
    return ResponseMessage(
      document: document,
      isLastMessageLeft: isLastMessageLeft,
    );
  }
}

imagePreview(BuildContext context, String url) {
  return showDialog(
    context: context,
    builder: (_) => Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(top: 100, left: 10, right: 10, bottom: 100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              child: PhotoView(
                imageProvider: NetworkImage(url),
              ),
            ),
          ),
        ),
        //buildFilterCloseButton(context),
      ],
    ),
  );
}

class SelfMessage extends StatelessWidget {
  final DocumentSnapshot document;
  final bool isLastMessageRight;
  const SelfMessage({
    Key? key,
    required this.document,
    required this.isLastMessageRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            document['type'] == 0
                // Text
                ? ChatBubble(message: document['content'], hasSentByUser: true,)
                : document['type'] == 2
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.95,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: ChatPost(
                            id: document['content'],
                          ),
                        ),
                      )
                    : Container(
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: const EdgeInsets.all(70.0),
                                decoration: const BoxDecoration(
                                  color: Color(0xffE8E8E8),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Material(
                                child: Text("Not Avilable"),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: document['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            imagePreview(
                              context,
                              document['content'],
                            );
                          },
                          padding: EdgeInsets.all(0),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight ? 20.0 : 10.0,
                            right: 10.0),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        isLastMessageRight
            ? Container(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('dd MMM kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      int.parse(
                        document['timestamp'],
                      ),
                    ),
                  ),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontStyle: FontStyle.normal),
                ),
                margin: const EdgeInsets.only(right: 10.0),
              )
            : Container()
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.message,
    required this.hasSentByUser,
  }) : super(key: key);

  final String message;
  final bool hasSentByUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          message,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 13),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
        decoration: BoxDecoration(
          color: hasSentByUser ? HexColor("#e1cbe7") : HexColor("#c4d1ec"),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        margin: hasSentByUser ? const EdgeInsets.only(
          bottom: 10.0,
          right: 10.0,
        ) : const EdgeInsets.only(left: 10.0),
      );
      // Container(
      //                 child: Text(
      //                   document['content'],
      //                   style: const TextStyle(
      //                       color: Colors.black,
      //                       fontWeight: FontWeight.normal,
      //                       fontSize: 13),
      //                 ),
      //                 padding:
      //                     const EdgeInsets.fromLTRB(20.0, 20.0, 15.0, 20.0),
      //                 decoration: BoxDecoration(
      //                     color: HexColor("#c4d1ec"),
      //                     // border: Border.all(color: Color(0xffE8E8E8)),
      //                     borderRadius: const BorderRadius.only(
      //                         topLeft: Radius.circular(20),
      //                         bottomRight: Radius.circular(20),
      //                         topRight: Radius.circular(20))),
      //                 margin: const EdgeInsets.only(left: 10.0),
      //               )
  }
}

class ResponseMessage extends StatelessWidget {
  final DocumentSnapshot document;
  final bool isLastMessageLeft;
  const ResponseMessage({
    Key? key,
    required this.document,
    required this.isLastMessageLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              document['type'] == 0
                  ? 
                  ChatBubble(message: document['content'], hasSentByUser: false,)                  
                  : document['type'] == 2
                      ? Padding(
                          padding: const EdgeInsets.only(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.95,
                            width: MediaQuery.of(context).size.width * 0.70,
                            child: ChatPost(
                              id: document['content'],
                            ),
                          ),
                        )
                      : Container(
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: const EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Material(
                                  child: Text("Not Avilable"),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              imagePreview(
                                context,
                                document['content'],
                              );
                            },
                            padding: const EdgeInsets.all(0),
                          ),
                          margin: const EdgeInsets.only(left: 10.0),
                        ),
            ],
          ),
          // Time
          isLastMessageLeft
              ? Container(
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp']))),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  margin:
                      const EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                )
              : Container()
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      margin: const EdgeInsets.only(bottom: 10.0),
    );
  }
}
