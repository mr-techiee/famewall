import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../global.dart';

class GridVideoView extends StatefulWidget {
  final String? url;
  final bool? play;
  final bool? isMute;
  final String? id;
  final String? profileImage;
  final String? firstName;
  final bool? isPost;
  final bool? isTrend;
  final PostObject? postObject;
  final List<PostObject>? trendList;
  GridVideoView({this.url, this.play,this.isMute,this.id,this.firstName,this.profileImage,this.isPost,this.isTrend,this.postObject,this.trendList});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<GridVideoView> with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  VideoPlayerController? controller;
  String visibleView="0.0";
  Duration? duration, position;
  bool isPause=false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    print(widget.url);
    controller = VideoPlayerController.network(
      widget.url!,
      //closedCaptionFile: _loadCaptions(),
    );

    controller!.addListener(() {
      if (mounted) setState(() {});
    });
    controller!.setLooping(false);
    controller!.initialize();

    if (widget.play != null && widget.play == true) {
      controller!.play();
      controller!.setLooping(false);
    }
    if(widget.isMute!){
      controller!.setVolume(0.0);
    }else{
      controller!.setVolume(1.0);
    }
    duration = controller!.value.duration;
    position = controller!.value.position;
    if (duration != null && position != null)
      position = (position! > duration!) ? duration : position;
  }
  @override
  void didUpdateWidget(GridVideoView oldWidget) {
    print("didUpdateWidget");
    if (widget.play != null &&
        widget.play == true &&
        oldWidget.play != widget.play) {

      if (widget.play!) {
        controller!.pause();
        controller!.setLooping(false);
      } else {
        controller!.pause();
      }
    }
    if(oldWidget.isMute != widget.isMute){
        if(widget.isMute!){
          controller!.setVolume(0.0);
        }else{
          controller!.setVolume(1.0);
        }
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
            child: InkWell(child: Container(
              // height: 300,
              child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VisibilityDetector(
                      key:Key('key_${widget.url!}'),
                      onVisibilityChanged: (VisibilityInfo info) {
                        var visiblePercentage = info.visibleFraction * 100;
                        print(info.key);

                        debugPrint(
                            "${info.visibleFraction} of my widget is visible");
                        visibleView=info.visibleFraction.toStringAsFixed(2);
                        print(visibleView);
                        if ((double.parse(visibleView) <0.5&&this.mounted)||isPause) {
                          if (controller != null) controller!.pause();
                        } else {
                          if (controller != null) controller!.pause();
                        }
                      },
                      child: Container(child: AspectRatio(aspectRatio: 1280/720,
                        child: VideoPlayer(controller!),),))),
            ),onTap: (){
              if(controller!.value.isPlaying){
                controller!.pause();
              }

            },),
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
          ),
          !controller!.value.isPlaying?Positioned.fill(child: InkWell(child: Container(child: Icon(Icons.play_circle,color: Colors.white,size: 40,),alignment: Alignment.center,),onTap: (){
            if(double.parse(visibleView)>0.4){
              controller!.pause();
            }
            if(widget.isPost!){
              if(widget.isTrend!=null&&widget.isTrend!){
                Navigator.of(context).pushNamed(HomeWidgetRoutes.screen16,
                    arguments: {
                      "postObject":widget.postObject,"trendList":widget.trendList
                    });
              }else{
                Navigator.of(context).pushNamed(HomeWidgetRoutes.screen9,
                    arguments: {
                      "postId":widget.id,
                      "firstName": widget.firstName,"profileimage":widget.profileImage
                    });
              }

            }else{
              Navigator.of(context)
                  .pushNamed(
                  HomeWidgetRoutes.screen10,
                  arguments: {
                    "isImage": false,
                    "filePath": widget.url,
                    "userName":  widget.firstName,
                    "profileImage": widget.profileImage
                  });
            }

          },)):Container()
        ],
      ),
    );
  }
}

//  Container(
//         // color: Colors.grey,
//         //  height: SizeConfig.blockSizeVertical * 40,
//         width: SizeConfig.screenWidth,
//         child: AspectRatio(
//           aspectRatio: controller.value.aspectRatio,
//           child: Stack(
//             alignment: Alignment.bottomCenter,
//             children: <Widget>[
//               widget.play == null
//                   ? VisibilityDetector(
//                       key: Key(
//                           DateTime.now().microsecondsSinceEpoch.toString()),
//                       onVisibilityChanged: (VisibilityInfo info) {
//                         debugPrint(
//                             "${info.visibleFraction} of my widget is visible");
//                         if (info.visibleFraction == 0) {
//                           if (controller != null) controller.pause();
//                         } else {
//                           if (controller != null) controller.play();
//                         }
//                       },
//                       child: VideoPlayer(controller))
//                   : VideoPlayer(controller),

//               // ClosedCaption(text: controller.value.caption.text),
//               _PlayPauseOverlay(controller: controller, id: widget.id),
//               //  VideoProgressIndicator(_controller, allowScrubbing: true),
//             ],
//           ),
//         ),
//       ),
