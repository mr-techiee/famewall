import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget with PreferredSizeWidget {
  const ChatAppBar({
    Key? key,
    required this.profileImage,
    required this.peerName,
  }) : super(key: key);

  final String profileImage;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.12,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: profileImage.isNotEmpty
                  ? CircleAvatar(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(profileImage),
                    )
                  : const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      peerName,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-medium",
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 100);
}
