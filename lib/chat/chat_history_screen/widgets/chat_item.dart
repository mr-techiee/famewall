import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/chat/chat_screen/widgets/chat_count_badge.dart';
import 'package:famewall/chat/color_utils.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatItem extends StatelessWidget {
  final Map<String, dynamic> document;

  const ChatItem({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                HomeWidgetRoutes.screen14,
                arguments: {
                  "peerId": document['id'],
                  "peerName": document['name'],
                  "profileImage": document['profileImage'] ?? "",
                },
              );
              // if (document['chatType'] != null &&
              // document['chatType'] == "group") {
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //         builder: (context) => GroupChat(
              //             peerID: document['id'],
              //             peerUrl: document['profileImage'],
              //             peerName: document['name'])));
              // } else {
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //         builder: (context) => Chat(
              //             peerID: document['id'],
              //             peerUrl: document['profileImage'],
              //             peerName: document['name'])));
              // }
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0, top: 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        //color: Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(0.0),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(width: 60),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 50,
                                    top: 10,
                                    right: 40,
                                    bottom: 5,
                                  ),
                                  child: SizedBox(
                                    // color: Colors.purple,
                                    width:
                                        MediaQuery.of(context).size.width - 200,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          // color: Colors.yellow,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              180,
                                          child: Text(
                                            document['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: "Poppins-Medium",
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                150,
                                            child: Text(
                                              DateFormat('dd MMM yyyy, kk:mm')
                                                  .format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                  int.parse(
                                                    document['timestamp'],
                                                  ),
                                                ),
                                              ),
                                              style: TextStyle(
                                                  color: HexColor("#343e57"),
                                                  fontSize: 11.0,
                                                  fontStyle: FontStyle.normal),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3),
                                          child: SizedBox(
                                            // color: Colors.red,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                150,
                                            height: 20,
                                            child: Text(
                                              document['type'] != null &&
                                                      document['type'] == 1
                                                  ? "📷 Image"
                                                  : document['content'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontFamily: "Poppins-Medium",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: document['badge'] > 0
                                    ? ChatCountBadge(
                                        badge: document['badge'].toString())
                                    : const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 25.0,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                        ),
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Material(
                        child: document['profileImage'] != null &&
                                document['profileImage'] != ''
                            ? CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: const CupertinoActivityIndicator(),
                                  width: 35.0,
                                  height: 35.0,
                                  padding: const EdgeInsets.all(10.0),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Material(
                                  child: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['profileImage'],
                                width: 35.0,
                                height: 35.0,
                                fit: BoxFit.cover,
                              )
                            : CircleAvatar(
                   backgroundColor: Colors.brown.shade800,
                   radius: 40,
                   child:  Text(document['name'].substring(0,2).toUpperCase()),
                 ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.black45,
            height: 0.5,
          ),
        ],
      ),
    );
  }
}
