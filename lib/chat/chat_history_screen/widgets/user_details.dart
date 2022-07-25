import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final SearchObject document;

  const UserDetails({
    Key? key,
    required this.document,
  }) : super(key: key);

  void navigateToChat(BuildContext context) {
    final userId = document.userid;
    final username = document.username;
    if (userId != null && username != null) {
      final peerName = username.isEmpty ? "${document.firstname} ${document.lastname}" : username;
      Navigator.of(context).pushNamed(
        HomeWidgetRoutes.screen14,
        arguments: {
          "peerId": userId,
          "peerName": peerName,
          "profileImage": document.profileimage,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Row(
              children: <Widget>[
                document.profileimage!.isNotEmpty
                    ? CircleAvatar(
                        radius: 24,
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(document.profileimage!),
                          radius: 22,
                        ),
                      )
                    : const CircleAvatar(
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/name.jpg'),
                          radius: 22,
                        ),
                      ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      document.firstname!,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal! * 4,
                          fontFamily: "Poppins-Medium",
                          color: Colors.black),
                    ),
                    Text(
                      document.username!,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal! * 3,
                          fontFamily: "Poppins-Medium",
                          color: Colors.grey),
                    ),
                    // Text(
                    //   document.email!,
                    //   style: TextStyle(
                    //       fontSize: SizeConfig.safeBlockHorizontal! * 3,
                    //       fontFamily: "Poppins-Medium",
                    //       color: Colors.grey),
                    // )
                  ],
                )),
                InkWell(
                  onTap: () {
                    navigateToChat(context);
                  },
                  child: Container(
                    child: const Text(
                      "Message",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Poppins-medium",
                          color: Colors.black,
                          fontSize: 12),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.grey),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(left: 2, right: 10),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(
            height: 2,
          ),
        ],
      ),
    );
  }
}
