import 'dart:io';

import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../global.dart';


class VideoViewWidget extends StatefulWidget {
  final File? url;
  final bool? play;
  final String? id;

  VideoViewWidget({this.url, this.play, this.id});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<VideoViewWidget> with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController? controller;

  Duration? duration, position;
  bool isPause=false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    print(widget.url);
    controller = VideoPlayerController.file(
     widget.url!,
      //closedCaptionFile: _loadCaptions(),
    );

    controller!.addListener(() {
      if (mounted) setState(() {});
    });
    controller!.setLooping(true);
    controller!.initialize();

    if (widget.play != null && widget.play == true) {
      controller!.play();
      controller!.setLooping(true);
    }

    duration = controller!.value.duration;
    position = controller!.value.position;
    if (duration != null && position != null)
      position = (position! > duration!) ? duration : position;
  }

  @override
  void didUpdateWidget(VideoViewWidget oldWidget) {
    print("didUpdateWidget");
    if (oldWidget.url != widget.url) {
      controller!.dispose();
      controller = null;
      print(widget.url);
      controller = VideoPlayerController.file(
        widget.url!,
        //closedCaptionFile: _loadCaptions(),
      );

      controller!.addListener(() {
        if (mounted) setState(() {});
      });
      controller!.setLooping(true);
      controller!.initialize();

      controller!.play();
      controller!.setLooping(true);

      duration = controller!.value.duration;
      position = controller!.value.position;
      if (duration != null && position != null)
        position = (position! > duration!) ? duration : position;
     /* if (widget.play!) {
        controller!.play();
        controller!.setLooping(true);
      } else {
        controller!.pause();
      }*/
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(AppLifecycleState.paused.toString());
    print("didChangeAppLifecycleState");
    if (state == AppLifecycleState.paused) {
      //controller!.pause();
      isPause=true;
      setState(() {

      });
    } else if (state == AppLifecycleState.resumed) {
      isPause=false;
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    controller!.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColorBlack,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              // height: 300,
              child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VisibilityDetector(
                      key:
                      Key(DateTime.now().microsecondsSinceEpoch.toString()),
                      onVisibilityChanged: (VisibilityInfo info) {
                        debugPrint(
                            "${info.visibleFraction} of my widget is visible");
                        /*if (info.visibleFraction == 0||isPause) {
                          if (controller != null) controller!.pause();
                        } else {
                          if (controller != null) controller!.play();
                        }*/
                      },
                      child: VideoPlayer(controller!))),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller!,
            builder: (context, VideoPlayerValue value, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      value.position.inMinutes.toString() +
                          ":" +
                          value.position.inSeconds.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
