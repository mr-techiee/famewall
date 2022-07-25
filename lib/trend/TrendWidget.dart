import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/story/AddStoryWidget.dart';
import 'package:famewall/pinch_zoom_image.dart';
import 'package:famewall/postRepository/PostListVM.dart';
import 'package:famewall/profile/profile.dart';
import 'package:famewall/search/search_new.dart';
import 'package:famewall/story/GridVideoView.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../HomeWidget.dart';
import '../PostScreen.dart';
import '../Utils.dart';
import '../global.dart';


class TrendWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenWidgetState();
  }
}

class HomeScreenWidgetState extends State<TrendWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool show = false;
  bool isMute = false;
  final PostListVM viewModel = PostListVM();
  List<PostObject> postLists = [];
  List<StoryObject> myStoryList = [];
  List<AllStoryMainObject> allStoriesList = [];
  UserResponse? userResponse;
  UserResponse? _userResponse;
  PostObject? postObject;
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
  bool isShowTrend=true;

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
  void didUpdateWidget(covariant TrendWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("oldWidget");
  }

  void getPostList() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse(
          "trend?perpage=20&page=" + pageNumber!.toString(),
          Status.TREND_LIST);
    });
  }



  void getProfileData() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse("myprofile", Status.GET_PROFILE);
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
    Future.delayed(Duration.zero, () {
      getProfileData();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is TrendList) {
          isLoading = false;
          var postList = event.data as TrendList;
          if (!postList.iserror!) {
            postLists.addAll(postList.postList);
            setState(() {});
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        } if (event.data is UserResponse) {
          var postList = event.data as UserResponse;
          if (!postList.iserror!) {
            userResponse = postList;
            _userResponse = postList;
            print(userResponse!.userId!);
            print("userResponse");
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
    if (controller!.position.userScrollDirection ==
        ScrollDirection.reverse) {
      isShowTrend=false;
      setState(() {

      });
    }
    if (controller!.position.userScrollDirection ==
        ScrollDirection.forward) {
      isShowTrend=true;
      setState(() {

      });
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

  void _showPopup(BuildContext context) async {
    //*get the render box from the context
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    //*get the global position, from the widget local position
    final offset = renderBox.localToGlobal(Offset.zero);

    //*calculate the start point in this case, below the button
    final left = offset.dx;
    final top = offset.dy + renderBox.size.height;
    //*The right does not indicates the width
    final right = left + renderBox.size.width;

    //*show the menu
    final value = await showMenu<String>(
        // color: Colors.red,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & Size(30, 30), // smaller rect, the touch area
            Offset.zero & renderBox.size // Bigger rect, the entire screen
            ),
        items: _options.entries.map<PopupMenuEntry<String>>((entry) {
          return PopupMenuItem(
            value: entry.key,
            child: SizedBox(
              // width: 200, //*width of popup
              child: Row(
                children: [
                  Icon(entry.value, color: Colors.redAccent),
                  const SizedBox(width: 10.0),
                  Text(entry.key)
                ],
              ),
            ),
          );
        }).toList());
    if (value != null) onTap();
    print("value");
    print(value);
  }

  Future<void> _pullRefresh() async {
    print("pulltorefresh");
    isLoading = false;
    pageNumber = 1;
    postLists = [];
    getPostList();
    // why use freshWords var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(appBar:isShowTrend?AppBar(bottom: PreferredSize(
          child: Container(margin: EdgeInsets.only(bottom: 5),
            color: Colors.grey.withOpacity(0.3),
            height: 0.5,
          ),
          preferredSize: Size.fromHeight(4.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Container(
          child: Text("Trend", style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold,  fontFamily: "Poppins-medium",
              fontSize: 14),), margin: EdgeInsets.only(right: 5),),
        elevation: 0,leading: Container(),):null,
          backgroundColor: Colors.white,
          body: RefreshIndicator(
              child: postLists.length>0?Container(child: _getMoviesListView1(postLists),margin: EdgeInsets.only(top: 0),):Container(),
              onRefresh: _pullRefresh)


      ),
    );
  }
  Widget _getMoviesListView1(List<PostObject>? postList) {
    return GridView.builder( controller:controller,itemCount: postList!.length,gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),itemBuilder: (context, position) {
      return postDetails1(postList![position], position);
    });
  }


  Widget _getMoviesListView(List<PostObject>? postList) {
    return ListView.separated(
      shrinkWrap: true,
      controller: controller,
      itemCount: postList!.length > 0 ? postList.length : 1,
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
    );
  }
  List<Widget> buildVideoImages1(PostObject document) {
    List<Widget> listWidget = [];
    for (int i = 0; i < document.imageList!.length; i++) {
      listWidget.add(document.imageList![i].isImage!
          ? InkWell(child: Container(
        constraints: BoxConstraints(
          minHeight: 320,
          maxHeight: 350,
          maxWidth: double.infinity,
          minWidth: double.infinity,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: 320,
                maxHeight: 350,
                maxWidth: double.infinity,
                minWidth: double.infinity,
              ),
              child: PinchZoomImage(
                image: CachedNetworkImage(
                  placeholder: (context, url) => Center(child: Container(
                    child: CupertinoActivityIndicator(),
                    width: 35.0,
                    height: 35.0,
                    padding: EdgeInsets.all(10.0),alignment: Alignment.center,
                  ),),
                  errorWidget: (context, url, error) => Material(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
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
                  imageUrl: document.imageList![i].filePath!,
                  imageBuilder: (context, imageProvider) => Container(
                    constraints: BoxConstraints(
                      minHeight: 320,
                      maxHeight: 350,
                      maxWidth: double.infinity,
                      minWidth: double.infinity,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // width: 35.0,
                  // height: 35.0,
                  fit: BoxFit.cover,
                ),
                zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
                hideStatusBarWhileZooming: true,
              ),
            ),
            document.imageList!.length>1?Positioned(
              right: 0,top: 0,
              child: Container(
                padding: EdgeInsets.only(left: 5,top: 3,bottom: 3,right: 5),
                decoration: BoxDecoration(
                    border: Border.all(
                        color:
                        Color(0xFFCA913B)),
                    borderRadius:
                    BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    color: Color(0xFF646460)),margin: EdgeInsets.only(top: 10,right: 10),
                child: Text(
                  (i+1).toString()+ " / "+document.imageList!.length.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                      "Poppins-medium",
                      fontSize: 7),
                ),
              ),
            ):Container()
          ],
        ),
      ),onTap: (){
        Navigator.of(context).pushNamed(HomeWidgetRoutes.screen16,
            arguments: {
              "postObject":document,"trendList":postLists
            });
      },)
          : Container(
        // height: 300,
        child: Stack(
          children: [
            GridVideoView(
              url: document.imageList![i].filePath,
              isMute: isMute,isTrend:true,isPost:true,postObject: document,trendList:postLists
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
            document.imageList!.length>1?Positioned(
              right: 0,top: 0,
              child: Container(
                padding: EdgeInsets.only(left: 5,top: 3,bottom: 3,right: 5),
                decoration: BoxDecoration(
                    border: Border.all(
                        color:
                        Color(0xFFCA913B)),
                    borderRadius:
                    BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    color: Color(0xFF646460)),margin: EdgeInsets.only(top: 10,right: 10),
                child: Text(
                  (i+1).toString()+ " / "+document.imageList!.length.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily:
                      "Poppins-medium",
                      fontSize: 10),
                ),
              ),
            ):Container()
          ],
        ),
      ));
    }
    return listWidget;
  }

  List<Widget> buildVideoImages(PostObject document) {
    List<Widget> listWidget = [];
    for (int i = 0; i < document.imageList!.length; i++) {
      listWidget.add(document.imageList![i].isImage!
          ? Container(
              constraints: BoxConstraints(
                minHeight: 320,
                maxHeight: 350,
                maxWidth: double.infinity,
                minWidth: double.infinity,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 320,
                      maxHeight: 350,
                      maxWidth: double.infinity,
                      minWidth: double.infinity,
                    ),
                    child: PinchZoomImage(
                      image: CachedNetworkImage(
                        placeholder: (context, url) => Center(child: Container(
                          child: CupertinoActivityIndicator(),
                          width: 35.0,
                          height: 35.0,
                          padding: EdgeInsets.all(10.0),alignment: Alignment.center,
                        ),),
                        errorWidget: (context, url, error) => Material(
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
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
                        imageUrl: document.imageList![i].filePath!,
                        imageBuilder: (context, imageProvider) => Container(
                          constraints: BoxConstraints(
                            minHeight: 320,
                            maxHeight: 350,
                            maxWidth: double.infinity,
                            minWidth: double.infinity,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // width: 35.0,
                        // height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
                      hideStatusBarWhileZooming: true,
                    ),
                  ),
                  document.imageList!.length>1?Positioned(
                    right: 0,top: 0,
                    child: Container(
                      padding: EdgeInsets.only(left: 5,top: 3,bottom: 3,right: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color:
                              Color(0xFFCA913B)),
                          borderRadius:
                          BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          color: Color(0xFF646460)),margin: EdgeInsets.only(top: 10,right: 10),
                      child: Text(
                    (i+1).toString()+ " / "+document.imageList!.length.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                            "Poppins-medium",
                            fontSize: 10),
                      ),
                    ),
                  ):Container()
                ],
              ),
            )
          : Container(
              // height: 300,
              child: Stack(
                children: [
                  VideoView(
                    url: document.imageList![i].filePath,
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
                  document.imageList!.length>1?Positioned(
                    right: 0,top: 0,
                    child: Container(
                      padding: EdgeInsets.only(left: 5,top: 3,bottom: 3,right: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color:
                              Color(0xFFCA913B)),
                          borderRadius:
                          BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          color: Color(0xFF646460)),margin: EdgeInsets.only(top: 10,right: 10),
                      child: Text(
                        (i+1).toString()+ " / "+document.imageList!.length.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily:
                            "Poppins-medium",
                            fontSize: 10),
                      ),
                    ),
                  ):Container()
                ],
              ),
            ));
    }
    return listWidget;
  }
  Widget postDetails1(PostObject? document, int position) {
    return InkWell(
      onDoubleTap: () {
        /*  startTime();
            setState(() {
              show = true;
            });
            if (document['likes'].contains(globalID)) {
            } else {
              likePost(document['timestamp'], document['idFrom']);
            }*/
      },
      child: Stack(
        children: <Widget>[
          Container(margin: EdgeInsets.only(right: 2,top: 2),
            constraints: BoxConstraints(
              minHeight: 320,
              maxHeight: 350,
              maxWidth: double.infinity,
              minWidth: double.infinity,
            ),
            child: Stack(
              children: [
                PageView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: buildVideoImages1(document!)),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget postDetails(PostObject? document, int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            /*  if (globalID == document['idFrom']) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(back: true)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PublicProfile(peerId: document['idFrom'])),
              );
            }*/
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  document!.profileimage!.length > 0
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CupertinoActivityIndicator(),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          errorWidget: (context, url, error) => Material(
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
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
                          imageUrl: document.profileimage!,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          // width: 35.0,
                          // height: 35.0,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/name.jpg'),
                            radius: 20,
                          ),
                        ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 4,
                  ),
                  document.location!.length > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              document.username!,
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal! * 3.5,
                                color: appColorBlack,
                                fontFamily: "Poppins-bold",
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 250,
                                  child: Text(
                                    document.location!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.safeBlockHorizontal! * 3,
                                        fontFamily: "Poppins-Medium",
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Text(
                          document.username!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 3.5,
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack),
                        ),
                ],
              ),
              onTap: () async{
                postObject = postLists[position];
               // viewPos = 2;
                streamSubscription!.pause();
               final v= await Navigator.of(context).pushNamed(HomeWidgetRoutes.screen2,arguments: {
                  "uObject":userResponse,"postObject":postObject
                });
                streamSubscription!.resume();
                //setState(() {});
                /*  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(userResponse: userResponse,postObject: postLists[position],)),
              );*/
              },
            ),
          ),
        ),
        Container(
          height: 2,
        ),
        !Utils.isEmpty(document.message!)?Container(
          margin: EdgeInsets.only(left: 15, top: 5, bottom: 5),
          child:  RegexTextHighlight(
            text: document.message!,
            highlightRegex: RegExp(r"\B@[a-zA-Z0-9]+\b"),
          ),
        ):Container(),
        InkWell(
          onDoubleTap: () {
            /*  startTime();
            setState(() {
              show = true;
            });
            if (document['likes'].contains(globalID)) {
            } else {
              likePost(document['timestamp'], document['idFrom']);
            }*/
          },
          child: Stack(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  minHeight: 320,
                  maxHeight: 350,
                  maxWidth: double.infinity,
                  minWidth: double.infinity,
                ),
                child: Stack(
                  children: [
                    PageView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: buildVideoImages(document)),

                  ],
                ),
              ),
             /* document.imageList!.length > 0
                  ?
                  : document.isImage!
                      ? Container(
                          constraints: BoxConstraints(
                            minHeight: 320,
                            maxHeight: 500,
                            maxWidth: double.infinity,
                            minWidth: double.infinity,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: 320,
                                  maxHeight: 500,
                                  maxWidth: double.infinity,
                                  minWidth: double.infinity,
                                ),
                                child: PinchZoomImage(
                                  image: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CupertinoActivityIndicator(),
                                      width: 35.0,
                                      height: 35.0,
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
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
                                    imageUrl: document.filepath!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      constraints: BoxConstraints(
                                        minHeight: 320,
                                        maxHeight: 500,
                                        maxWidth: double.infinity,
                                        minWidth: double.infinity,
                                      ),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // width: 35.0,
                                    // height: 35.0,
                                    fit: BoxFit.cover,
                                  ),
                                  zoomedBackgroundColor:
                                      Color.fromRGBO(240, 240, 240, 1.0),
                                  hideStatusBarWhileZooming: true,
                                ),
                              ),
                              Positioned(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/like_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFCA913B)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF646460)),
                                                child: Text(
                                                  " " +
                                                      document.liked
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/heart_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFCA913B)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFFE91E63)),
                                                child: Text(
                                                  " " +
                                                      document.favourite
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/star_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFCA913B)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFFCA913B)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/forward-default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFCA913B)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF000000)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/bookmark_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFCA913B)),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF0B4980)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                bottom: 7,
                              )
                            ],
                          ),
                        )
                      : Container(
                          // height: 300,
                          child: Stack(
                            children: [
                              VideoView(
                                url: document.filepath,
                                isMute: isMute,
                              ),
                              Positioned(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/like_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        Color(0xFFCA913B)),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF646460)),
                                                child: Text(
                                                  " " +
                                                      document.liked
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/heart_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        Color(0xFFCA913B)),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFFE91E63)),
                                                child: Text(
                                                  " " +
                                                      document.favourite
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/star_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        Color(0xFFCA913B)),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFFCA913B)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/forward-default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        Color(0xFFCA913B)),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF000000)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/bookmark_default.png"),
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: 10, right: 10),
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        Color(0xFFCA913B)),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    color: Color(0xFF0B4980)),
                                                child: Text(
                                                  " " +
                                                      document.shared
                                                          .toString() +
                                                      " ",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                bottom: 7,
                              ),
                              Positioned(
                                width: MediaQuery.of(context).size.width,
                                child: InkWell(
                                  child: Container(
                                    child: Icon(
                                      isMute
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
                              )
                            ],
                          ),
                        ),*/
              show == true
                  ? Positioned.fill(
                      child: AnimatedOpacity(
                          opacity: show ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 700),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: Colors.red,
                            size: 100,
                          )))
                  : Container(),
            ],
          ),
        ),
        Container(margin: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage(
                            "assets/images/like_default.png"),
                      ),
                      margin: EdgeInsets.only(
                          top: 10, right: 10),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                Color(0xFFCA913B)),
                            borderRadius:
                            BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Color(0xFF646460)),
                        child: Text(
                          " " +
                              document.liked
                                  .toString() +
                              " ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage(
                            "assets/images/heart_default.png"),
                      ),
                      margin: EdgeInsets.only(
                          top: 10, right: 10),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                Color(0xFFCA913B)),
                            borderRadius:
                            BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Color(0xFFE91E63)),
                        child: Text(
                          " " +
                              document.favourite
                                  .toString() +
                              " ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage(
                            "assets/images/star_default.png"),
                      ),
                      margin: EdgeInsets.only(
                          top: 10, right: 10),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                Color(0xFFCA913B)),
                            borderRadius:
                            BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Color(0xFFCA913B)),
                        child: Text(
                          " " +
                              document.starred
                                  .toString() +
                              " ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage(
                            "assets/images/forward-default.png"),
                      ),
                      margin: EdgeInsets.only(
                          top: 10, right: 10),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                Color(0xFFCA913B)),
                            borderRadius:
                            BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Color(0xFF000000)),
                        child: Text(
                          " " +
                              document.shared
                                  .toString() +
                              " ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /* Container(
                              child: Stack(
                                children: [
                                  Container(
                                    child: Image(
                                      image: AssetImage(
                                          "assets/images/bookmark_default.png"),
                                    ),
                                    margin: EdgeInsets.only(
                                        top: 10, right: 10),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                              Color(0xFFCA913B)),
                                          borderRadius:
                                          BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          color: Color(0xFF0B4980)),
                                      child: Text(
                                        " " +
                                            document.shared
                                                .toString() +
                                            " ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )*/
            ],
          ),
        ),
        document.liked_users.length > 0
            ? Padding(
          padding: const EdgeInsets.only(left: 5, right: 20, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              !Utils.isEmpty(document
                  .liked_users[document.liked_users.length - 1]
                  .profileimage)
                  ? Container(
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFC4861A),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(document
                        .liked_users[
                    document.liked_users.length - 1]
                        .profileimage),
                    radius: 14,
                  ),
                ),
                margin: EdgeInsets.only(right: 5),
              )
                  : Container(),
              Expanded(
                child: RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 14.0,
                    ),
                    children: <TextSpan>[
                      new TextSpan(
                          text: "Liked by ",
                          style: TextStyle(
                              fontSize:
                              SizeConfig.safeBlockHorizontal! * 3,
                              fontStyle: FontStyle.normal,
                              color: Colors.black,
                              fontFamily: "Poppins-medium",
                              fontWeight: FontWeight.normal)),
                      TextSpan(
                          text: document
                              .liked_users[
                          document.liked_users.length - 1]
                              .firstname,
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! * 3,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      int.parse(document.liked)>1?TextSpan(
                          text: " and ",
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! * 3,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)):TextSpan(),
                      int.parse(document.liked)>1?TextSpan(
                          text:
                          (int.parse(document.liked) - 1).toString()+" Others",
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! * 3,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)):TextSpan(text: ""),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            : Container(),
      ],
    );
  }

  Widget getProfileView(){
    var uObj=userResponse;
  return Profile();
}
  Future<bool> _backPressed() async {
    //Checks if current Navigator still has screens on the stack.
    if (viewPos != 0) {
      print(currentTabPos);
      print("viewPos");
      streamSubscription!.resume();
      getProfileData();
      viewPos = 0;
      setState(() {});
      return Future<bool>.value(false);
    }
    return Future<bool>.value(true);
  }
}
