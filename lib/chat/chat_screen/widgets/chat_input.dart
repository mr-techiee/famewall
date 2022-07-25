import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/chat/chat_screen/provider/chat_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({Key? key}) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final textEditingController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  late ChatScreenProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ChatScreenProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    textFieldFocusNode.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Provider.of<ChatScreenProvider>(context, listen: false).pickImage();
                },
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.black, fontSize: 15.0),
              controller: textEditingController,
              // maxLines: null,
              keyboardType: TextInputType.multiline,
              focusNode: textFieldFocusNode,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                // suffixIcon: GestureDetector(
                //   onTap: () async {
                //     setState(() {
                //       textFieldFocusNode.unfocus();
                //       textFieldFocusNode.canRequestFocus = false;
                //     });

                //     // GiphyGif gif = await GiphyGet.getGif(
                //     //   context: context,
                //     //   apiKey:
                //     //       "5O0S0RL6CRLQj3Ch8wnTFctv7lswZt0G", //YOUR API KEY HERE
                //     //   lang: GiphyLanguage.spanish,
                //     // );

                //     // if (gif != null) {
                //     //   setState(() {
                //     //     _gif = gif;

                //     //     onSendMessage(gif.images.original.url, 1);
                //     //     print(gif.images.original.url);
                //     //   });
                //     // }
                //   },
                //   child: Container(
                //     child: const FittedBox(
                //       alignment: Alignment.center,
                //       fit: BoxFit.fitHeight,
                //       child: IconTheme(
                //         data: IconThemeData(),
                //         child: Icon(
                //           Icons.gif,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),

          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  String content = textEditingController.text.trim();
                  if (content.isNotEmpty) {
                    setState(() {
                      textFieldFocusNode.unfocus();
                      textFieldFocusNode.canRequestFocus = false;
                      textEditingController.clear();
                    });
                    provider.sendMessage(content, 0);
                  }                  
                },
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.7),
        ),
        color: Colors.white,
      ),
    );
  }
}