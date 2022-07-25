import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../FollowerListWidget.dart';
import '../HomeWidget.dart';
import '../Utils.dart';
import '../global.dart';
import '../helper/sizeConfig.dart';
import '../pinch_zoom_image.dart';

// ignore: must_be_immutable
class TrendDetails extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<TrendDetails> {
  List newProjectList = [];

  bool isMute = false;
  bool isInView = false;
  BaseApiService baseApiService = NetworkApiService();
  List<PostObject> postLists = [];
  PostObject? postObject;
  bool show = false;
  int showPos = 0;
  int selectedPostPos = 0;
  StreamSubscription? streamSubscription = null;
  UserResponse? userResponse;
  int viewPos = 0;
  bool isFirstTime = false;
  String? postId;
  PostObject? postDetailObject;
  String? userId = "";
  String? firstname = "";
  String? lastname = "";
  String? email = "";
  String? mobileno = "";
  String? profileimage = "";
  String? bio = "";
  String? gender = "";
  String? location = "";
  String? username = "";
  String? website = "";
  String? followercount = "";
  String? followingcount = "";
  void getArguments() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
   // firstname = arguments["firstName"];
    //postId = arguments["postId"];
    postDetailObject = arguments["postObject"];
    postLists.add(postDetailObject!);
    List<PostObject> spostLists=arguments["trendList"];
    spostLists.removeWhere((element) => element.postid==postDetailObject!.postid);
    postLists.addAll(spostLists);

    //profileimage = arguments["profileimage"];
    /*getPostDetails();
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is PostDetailObject) {
          postDetailObject = event.data as PostDetailObject;

          if (mounted) {
            setState(() {});
          }
        }
      }
    });*/
  }

  @override
  void initState() {
    super.initState();
  }

  void getPostDetails() {
    Future.delayed(Duration(seconds: 1), () {
      baseApiService.getResponse("post/detail/" + postId!, Status.POST_DETAILS);
    });
  }

  @override
  void dispose() {
    super.dispose();
    //streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (!isFirstTime) {
      isFirstTime = true;
      getArguments();
    }

    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "Trend",
                style: TextStyle(
                    fontFamily: "Poppins-bold",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    if (viewPos == 0) {
                      Navigator.maybePop(context);
                    } else {
                      streamSubscription!.resume();
                      viewPos = 0;
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: appColorBlack,
                  )),
              actions: [],
            ),
            body: postLists.length>0
                ? _getMoviesListView(postLists)
                : Container()));
  }
  Widget _getMoviesListView(List<PostObject>? postList) {
    return Container(
        child:
        PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemCount: postList!.isEmpty ? 0 : postList.length,
          itemBuilder: (BuildContext context, int position) =>
              postDetails(postList![position], position),
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
/*
  Widget _getMoviesListView(List<PostObject>? postList) {
    return ListView.separated(
      shrinkWrap: true,
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
*/
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
  startTime() async {
    var _duration = new Duration(milliseconds: 500);
    return new Timer(_duration, navigationPage);
  }

  navigationPage() {
    setState(() {
      show = false;
    });
  }

  void likePost(String id, String type) {
    var request = {
      'postid': id,
      'liketype': type,
    };
    print("request");
    print(request);
    baseApiService.postResponse("likepost", request, Status.FOLLOW);
  }

  void unlikePost(String id, String type) {
    var request = {
      'postid': id,
      'liketype': type,
    };
    print("request");
    baseApiService.postResponse("unlikepost", request, Status.FOLLOW);
  }

/*
  Widget postDetails(PostObject? document, int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            *//*  if (globalID == document['idFrom']) {
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
            }*//*
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
               *//* postObject = postLists[position];
                // viewPos = 2;
                streamSubscription!.pause();
                final v= await Navigator.of(context).pushNamed(HomeWidgetRoutes.screen2,arguments: {
                  "uObject":userResponse,"postObject":postObject
                });
                streamSubscription!.resume();*//*
                //setState(() {});
                *//*  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(userResponse: userResponse,postObject: postLists[position],)),
              );*//*
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
            *//*  startTime();
            setState(() {
              show = true;
            });
            if (document['likes'].contains(globalID)) {
            } else {
              likePost(document['timestamp'], document['idFrom']);
            }*//*
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
              *//* Container(
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
                            )*//*
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
  }*/
  Future<bool> _backPressed() async {
    print("onBackPressed");
    //Checks if current Navigator still has screens on the stack.
    if (viewPos != 0) {
      viewPos = 0;
      setState(() {});
      return Future<bool>.value(false);
    }
    return Future<bool>.value(true);
  }
  Widget postDetails(PostObject? document, int position) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
                    width: SizeConfig.blockSizeHorizontal! * 3,
                  ),
                  Expanded(child: Container(child: document.location!.length > 0
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
                  ),)),
                  /*InkWell(child: Container(child: Icon(Icons.more_horiz),margin: EdgeInsets.only(right: 10),),onTap: (){
                    showMoreOptionBottomSheet(position);
                  },)*/
                ],
              ),
              onTap: () async {
                postObject = postLists[position];
                // viewPos = 2;
                streamSubscription!.pause();
                final v = await Navigator.of(context)
                    .pushNamed(HomeWidgetRoutes.screen2, arguments: {
                  "uObject": userResponse,
                  "postObject": postObject
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
          child: RegexTextHighlight(
            text: document.message!,
            highlightRegex: RegExp(r"\B@[a-zA-Z0-9]+\b"),
          ) /*Text(
            document.message!,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal! * 3.5,
                fontFamily: "Poppins-Medium",
                color: appColorBlack),
          )*/
          ,
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
                      children: buildVideoImages(document),
                      onPageChanged: (pos) {
                        postLists[position].taggedList =
                            postLists[position].imageList![pos].taggedList;
                        setState(() {});
                      },
                    ),

                  ],
                ),
              ),
              selectedPostPos == position && show == true
                  ? Positioned.fill(
                  child: Lottie.asset(showPos == 0
                      ? 'assets/images/like.json'
                      : showPos == 1
                      ? 'assets/images/heart.json'
                      : "assets/images/star.json") /*AnimatedOpacity(
                          opacity: show ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 700),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: Colors.red,
                            size: 100,
                          ))*/
              )
                  : Container(),
            ],
          ),
        ),
        Container(margin: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage(
                              "assets/images/like_default.png"),
                        ),
                        margin:
                        EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFF646460)),
                          child: Text(
                            " " + document.liked.toString() + " ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  startTime();
                  setState(() {
                    print("postListsliked");
                    print(postLists[position].is_liked);
                    print(postLists[position].liketype);
                    if (postLists[position].is_liked == "no") {
                      selectedPostPos = position;
                      showPos = 0;
                      show = true;
                      postLists[position].is_liked = "yes";
                      postLists[position].liketype = "normal";
                      postLists[position].liked =
                          (int.parse(postLists[position].liked) +
                              1)
                              .toString();
                      likePost(document.postid, "normal");
                    } else {
                      if (postLists[position].liketype ==
                          "normal") {
                        postLists[position].is_liked = "no";
                        postLists[position].liketype = "";
                        postLists[position].liked = (int.parse(
                            postLists[position].liked) -
                            1)
                            .toString();
                        unlikePost(document.postid, "normal");
                      } else {
                        if (postLists[position].liketype ==
                            "heart") {
                          postLists[position].favourite =
                              (int.parse(postLists[position]
                                  .favourite!) -
                                  1)
                                  .toString();
                        } else if (postLists[position].liketype ==
                            "star") {
                          postLists[position].starred =
                              (int.parse(postLists[position]
                                  .starred!) -
                                  1)
                                  .toString();
                        }
                        unlikePost(document.postid,
                            postLists[position].liketype);
                        selectedPostPos = position;
                        showPos = 0;
                        show = true;
                        postLists[position].is_liked = "yes";
                        postLists[position].liketype = "normal";
                        postLists[position].liked = (int.parse(
                            postLists[position].liked) +
                            1)
                            .toString();
                        likePost(document.postid, "normal");
                      }
                    }
                  });
                },
              ),
              InkWell(
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage(
                              "assets/images/heart_default.png"),
                        ),
                        margin:
                        EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFFE91E63)),
                          child: Text(
                            " " +
                                document.favourite.toString() +
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
                onTap: () {
                  startTime();
                  setState(() {
                    if (postLists[position].is_liked == "no") {
                      selectedPostPos = position;
                      showPos = 1;
                      show = true;
                      postLists[position].is_liked = "yes";
                      postLists[position].liketype = "heart";
                      postLists[position].favourite = (int.parse(
                          postLists[position]
                              .favourite!) +
                          1)
                          .toString();
                      likePost(document.postid, "heart");
                    } else {
                      if (postLists[position].liketype ==
                          "heart") {
                        postLists[position].is_liked = "no";
                        postLists[position].liketype = "";

                        postLists[position].favourite =
                            (int.parse(postLists[position]
                                .favourite!) -
                                1)
                                .toString();
                        unlikePost(document.postid, "heart");
                      } else {
                        if (postLists[position].liketype ==
                            "normal") {
                          postLists[position].liked = (int.parse(
                              postLists[position]
                                  .liked!) -
                              1)
                              .toString();
                        } else if (postLists[position].liketype ==
                            "star") {
                          postLists[position].starred =
                              (int.parse(postLists[position]
                                  .starred!) -
                                  1)
                                  .toString();
                        }
                        unlikePost(document.postid,
                            postLists[position].liketype);
                        selectedPostPos = position;
                        showPos = 1;
                        show = true;
                        postLists[position].is_liked = "yes";
                        postLists[position].liketype = "heart";
                        postLists[position].favourite =
                            (int.parse(postLists[position]
                                .favourite!) +
                                1)
                                .toString();
                        likePost(document.postid, "normal");
                      }
                    }
                    /* postLists[position].favourite=(int.parse(postLists[position].favourite!)+1).toString();
                                  likePost(document.postid, "heart");*/
                  });
                },
              ),
              InkWell(
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage(
                              "assets/images/star_default.png"),
                        ),
                        margin:
                        EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFFCA913B)),
                          child: Text(
                            " " +
                                document.starred.toString() +
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
                onTap: () {
                  startTime();
                  setState(() {
                    if (postLists[position].is_liked == "no") {
                      selectedPostPos = position;
                      showPos = 2;
                      show = true;
                      postLists[position].is_liked = "yes";
                      postLists[position].liketype = "star";
                      postLists[position].starred = (int.parse(
                          postLists[position].starred!) +
                          1)
                          .toString();
                      likePost(document.postid, "star");
                    } else {
                      if (postLists[position].liketype ==
                          "star") {
                        postLists[position].is_liked = "no";
                        postLists[position].liketype = "";
                        postLists[position].starred = (int.parse(
                            postLists[position]
                                .starred!) -
                            1)
                            .toString();
                        unlikePost(document.postid, "star");
                      } else {
                        if (postLists[position].liketype ==
                            "normal") {
                          postLists[position].liked = (int.parse(
                              postLists[position]
                                  .liked!) -
                              1)
                              .toString();
                        } else if (postLists[position].liketype ==
                            "heart") {
                          postLists[position].favourite =
                              (int.parse(postLists[position]
                                  .favourite!) -
                                  1)
                                  .toString();
                        }
                        unlikePost(document.postid,
                            postLists[position].liketype);
                        selectedPostPos = position;
                        showPos = 2;
                        show = true;
                        postLists[position].is_liked = "yes";
                        postLists[position].liketype = "star";
                        postLists[position].starred = (int.parse(
                            postLists[position]
                                .starred!) +
                            1)
                            .toString();
                        likePost(document.postid, "star");
                      }
                    }
                  });
                },
              ),
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage(
                            "assets/images/forward-default.png"),
                      ),
                      margin: EdgeInsets.only(top: 10, right: 10),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFCA913B)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Color(0xFF000000)),
                        child: Text(
                          " " + document.shared.toString() + " ",
                          style: TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage(
                              "assets/images/bookmark_default.png"),
                        ),
                        margin:
                        EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFF000000)),
                          child: Text(
                            " " +
                                postLists[position]
                                    .taggedList
                                    .length
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
                onTap: () {
                /*  if (postLists[position].taggedList.length > 0) {
                   *//* showTaggedListSheet(
                        postLists[position].taggedList);*//*
                  }*/
                },
              ),
            ],
          ),
        ),
        document.liked_users.length > 0
            ? Padding(
          padding: const EdgeInsets.only(left: 15, right: 20, top: 10),
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
                              .userName,
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! * 3,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      document.totalLikedCount > 1
                          ? TextSpan(
                          text: " and ",
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! *
                                  3,
                              color: Colors.black,
                              fontWeight: FontWeight.normal))
                          : TextSpan(),
                      document.totalLikedCount > 1
                          ? TextSpan(
                          text: (document.totalLikedCount-1)
                              .toString() +
                              " Others",
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              fontSize:
                              SizeConfig.safeBlockHorizontal! *
                                  3,
                              color: Colors.black,
                              fontWeight: FontWeight.bold))
                          : TextSpan(text: ""),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            : Container(),
        Container(margin: EdgeInsets.only(left: 15,top: 5),child: Text(
          document.createdOn!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize:
              SizeConfig.safeBlockHorizontal! * 3,
              fontFamily: "Poppins-Medium",
              color: Colors.grey),
        ),)
      ],
    );
  }
  showMoreOptionBottomSheet(int postion) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 3 + 35,
            color: Color(0x00737373),
            child: Column(children: [
              postLists[postion].userid==userResponse!.userId?InkWell(child: Container(padding: EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 10),child: Row(children: [
                Icon(Icons.delete,color: Colors.redAccent,),
                Container(child: Text("DELETE",style: TextStyle(color:Colors.redAccent),),margin: EdgeInsets.only(left: 10),),
              ],),),onTap: (){
                Navigator.of(context).pop();
                deletePost( postLists[postion].postid);
                postLists.removeAt(postion);
                setState(() {

                });
              },):Container()
            ],),
          );
        });
  }
  void deletePost(String id) {
    baseApiService.deleteResponse("post/" + id, Status.FOLLOW);
  }
  getThumnail(path) async {
    return await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
  }
}
