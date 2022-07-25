import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/pinch_zoom_image.dart';
import 'package:famewall/postRepository/PostListVM.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/profile/profile.dart';
import 'package:famewall/search/search_new.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'BubbleWidget.dart';
import 'HomeWidget.dart';
import 'PostScreen.dart';
import 'PrefUtils.dart';
import 'TrianglePath.dart';
import 'Utils.dart';
import 'WebviewWidget.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';
import 'global.dart';
import 'helper/sizeConfig.dart';

class FollowerVideoWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return FollowerVideoWidgetState();
  }

}
class FollowerVideoWidgetState extends State<FollowerVideoWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  bool show = false;
  int showPos = 0;
  int selectedPostPos = 0;
  bool isMute = false;
  final PostListVM viewModel = PostListVM();
  List<FollowerVideoObject> postLists = [];

  UserResponse? userResponse;
  UserResponse? _userResponse;
  int viewPos = 0;
  StreamSubscription? streamSubscription = null;
  GlobalKey btnKey = GlobalKey();
  GlobalKey btnKey2 = GlobalKey();
  GlobalKey btnKey3 = GlobalKey();
  Animation<double>? _animation;
  AnimationController? _animationController;
  bool isFab = false;
  BaseApiService baseApiService = NetworkApiService();
  ScrollController? controller;
  bool? isLoading = false;
  int? pageNumber = 1;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state:" + state.toString());
    if (state == AppLifecycleState.resumed) {
      streamSubscription!.resume();
    }
    if (state == AppLifecycleState.paused) {
      streamSubscription!.pause();
    }
  }

  @override
  void didUpdateWidget(covariant FollowerVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("oldWidget");
  }

  void getPostList() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse(
          "followervideos?perpage=10&page=" + pageNumber!.toString(),
          Status.FOLLOWER_VIDEO);
    });
  }


  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
    isLoading = false;
    pageNumber = 1;
    postLists = [];
    getPostList();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
    CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    /*streamSubscription = eventBus.on<int>().listen((event) {
      if (event == 1) {
        viewPos = 0;
        setState(() {});
      }
    });*/
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is FollowerVideoList) {
          isLoading = false;
          var postList = event.data as FollowerVideoList;
          if (!postList.iserror!) {
            postLists.addAll(postList.followerVideoList);
            setState(() {});
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        }
      }
    });
  }

  void _scrollListener() {
    print(controller!.position.extentAfter);
    if (controller!.position.maxScrollExtent == controller!.offset) {
      if (postLists.length >= (10 * pageNumber!) && !isLoading!) {
        pageNumber = (pageNumber! + 1)!;
        isLoading = true;
        print("loadMore");
        getPostList();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller!.removeListener(_scrollListener);
    streamSubscription?.cancel();
  }

  var _tapPosition;

  static const Map<String, IconData> _options = {
    'Post': Icons.post_add,
    'Reel': Icons.camera,
  };

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostScreen()),
    );
  }


  Future<void> _pullRefresh() async {
    print("pulltorefresh");
    isLoading = false;
    pageNumber = 1;
    postLists = [];
    getPostList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:  RefreshIndicator(
            child: postLists.length>0?_getMoviesListView(postLists):Center(child: Container(child: Text("No Video Posts"),),),
            onRefresh: _pullRefresh),
      ),
    );
  }

  Widget _getMoviesListView(List<FollowerVideoObject>? postList) {
    return Container(
        child:
        PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemCount: postList!.isEmpty ? 0 : postList.length,
          itemBuilder: (BuildContext context, int index) =>
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Stack(children: [
                  Container(
                    child: VideoView(
                      url: postList![index].filepath,isShowTime: false,
                      isMute: isMute,
                    ),
                  ),
                  Positioned(child: userDetails(postList![index]),)
                ],),
              ),
        )
    )/*ListView.separated(
      shrinkWrap: true,
      controller: controller,
      itemCount: postList!.length,
      itemBuilder: (context, position) {
        print(position.toString() + " testing");
        print(postList!.length!.toString());
        return postDetails(postList![position], position);
      },
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.white,
        );
      },
    )*/;
  }


  Widget postDetails(FollowerVideoObject? document, int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        InkWell(
          onDoubleTap: () {
          },
          child: Stack(
            children: <Widget>[
              Container(
                child: Stack(
                  children: [
                   
                    Container(
                      child: Stack(
                        children: [
                          VideoView(
                            url: document!.filepath,
                            isMute: isMute,
                          ),
                          Positioned(
                            width: MediaQuery.of(context).size.width,
                            child: InkWell(
                              child: Container(
                                child: Icon(
                                  !isMute
                                      ? Icons.volume_down_outlined
                                      : Icons.volume_mute,
                                  color: Colors.white,
                                ),
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10, top: 10),
                              ),
                              onTap: () {
                                if (isMute) {
                                  isMute = false;
                                } else {
                                  isMute = true;
                                }
                                setState(() {});
                              },
                            ),
                            top: 7,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  startTime() async {
    var _duration = new Duration(milliseconds: 500);
    return new Timer(_duration, navigationPage);
  }

  navigationPage() {
    setState(() {
      show = false;
    });
  }
  Widget userDetails(FollowerVideoObject? document) {
    return Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: Row(
            children: <Widget>[
              document!.profileimage!.length > 0
                  ? CircleAvatar(
                radius: 24,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(document.profileimage!),
                  radius: 22,
                ),
              )
                  : Container(
                child: CircleAvatar(
                  child: CircleAvatar(
                    backgroundImage:
                    AssetImage('assets/images/name.jpg'),
                    radius: 22,
                  ),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 4,
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Container(
                  child: Text(
                    document.username!,

                    style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 4,
                        fontFamily: "Poppins-Medium",
                        color: Colors.white),
                  ),

                ),
                Container(
                  child: Text(
                    document.email!,

                    style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 3,
                        fontFamily: "Poppins-Medium",
                        color: Colors.grey),
                  ),

                )
              ],)),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 2,
        ),
      ],
    ),margin: EdgeInsets.only(top: 5),height: 100,);
  }

}
/*class VideoWidget2 extends StatefulWidget {

  final bool play;
  final String url;

  const VideoWidget2({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}


class _VideoWidgetState extends State<VideoWidget2> {
  VideoPlayerController? videoPlayerController ;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = new VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = videoPlayerController!.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  } // This closing tag was missing

  @override
  void dispose() {
    videoPlayerController!.dispose();
    //    widget.videoPlayerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return new Container(

            child: Card(
              key: new PageStorageKey(widget.url),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chewie(
                      key: new PageStorageKey(widget.url),
                      controller: ChewieController(
                        videoPlayerController: videoPlayerController,
                        aspectRatio: 3 / 2,
                        // Prepare the video to be played and display the first frame
                        autoInitialize: true,
                        looping: false,
                        autoPlay: false,
                        // Errors can occur for example when trying to play a video
                        // from a non-existent URL
                        errorBuilder: (context, errorMessage) {
                          return Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return Center(
            child: CircularProgressIndicator(),);
        }
      },
    );
  }
}*/
