import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/chat/chat_screen/provider/chat_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatPost extends StatefulWidget {
  String id;

  ChatPost({
    Key? key,
    required this.id,
  }) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<ChatPost> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.transparent, body: allPost(context),
      ),
    );
  }

  Widget allPost(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('post')
          .doc(widget.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        } else {
          return postDetails(
              (snapshot as DocumentSnapshot).data as DocumentSnapshot,);
        }
      },
    );
  }

  Widget postDetails(DocumentSnapshot document) {
    // final userId = Provider.of<ChatScreenProvider>(context, listen: false).userId;
    return GestureDetector(
      onTap: () {
        // if (document['idFrom'] != userId)
          // const Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) =>
          //           PublicProfile(peerId: document['idFrom'])),
          // );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: document['userImage'].length > 0
                        ? NetworkImage(document['userImage'])
                        : NetworkImage(
                            "https://www.nicepng.com/png/detail/136-1366211_group-of-10-guys-login-user-icon-png.png"),
                    radius: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                  Expanded(
                    child: Text(
                      document['userName'],
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontFamily: "Poppins-Medium",
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 2,
            ),
            // InkWell(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               ViewPublicPost(id: document['timestamp'])),
            //     );
            //   },
            //   child: Stack(
            //     children: <Widget>[
            //       Container(
            //           height: MediaQuery.of(context).size.width * 0.35,
            //           width: MediaQuery.of(context).size.width,
            //           child: Image.network(
            //             document['videoUrl'].length > 0
            //                 ? document['videoUrl']
            //                 : document['content'],
            //             fit: BoxFit.cover,
            //           ))
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 5, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: document['userName'],
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontStyle: FontStyle.normal,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " " + document["caption"],
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
