import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/profile/editprofile1.dart';
import 'package:famewall/story/GridVideoView.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../FollowerListWidget.dart';
import '../HomeWidget.dart';
import '../Utils.dart';
import '../global.dart';
import '../helper/sizeConfig.dart';
import '../pinch_zoom_image.dart';

// ignore: must_be_immutable
class HashPostDetails extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<HashPostDetails> {
  List newProjectList = [];

  bool isMute = false;
  bool isInView = false;
  BaseApiService baseApiService = NetworkApiService();
  StreamSubscription? streamSubscription = null;
  UserResponse? userResponse;
  int viewPos = 0;
  bool isFirstTime = false;
  String? postId;
  PostDetailObject? postDetailObject;
  List<PostObject>? postList=[];
  String? userId = "";
  String HashTag = "";
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
  ScrollController? controller;

  bool? isLoading = false;
  int? pageNumber = 1;
  void getArguments() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
   // firstname = arguments["firstName"];
    //postId = arguments["postId"];
    //userId = arguments["userId"];
    HashTag = arguments["HashTag"];
    //profileimage = arguments["profileimage"];
    getPostDetails();
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is HashPostDetailsList) {
          HashPostDetailsList postListObj = event.data as HashPostDetailsList;
          List<PostObject>sPost=postListObj.postList.where((element) => element.postid==postId).toList();
          postList!.addAll(sPost);
          List<PostObject>sList=postListObj.postList;
          sList.removeWhere((element) => element.postid==postId);
          postList!.addAll(sList);
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);

  }
  void _scrollListener() {
    print(controller!.position.extentAfter);
    if (controller!.position.maxScrollExtent == controller!.offset) {
      if (postList!.length >= (10 * pageNumber!) && !isLoading!) {
        pageNumber = (pageNumber! + 1)!;
        isLoading = true;
        print("loadMore");
        getPostDetails();
      }
    }

  }
  void getPostDetails() {
    Future.delayed(Duration(seconds: 1), () {
      var request = {
        "hashvalue":HashTag
      };
      baseApiService.postResponse("hashdatas?perpage=10&page="+pageNumber.toString(), request, Status.HAST_LIST);
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (!isFirstTime) {
      isFirstTime = true;
      getArguments();
    }

    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Text(
                    "Posts",
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
                body:postList!.length>0
                    ? ListView.builder(controller: controller,itemCount: postList!.length,itemBuilder: (BuildContext context, int position){
                      return getPost(postList![position]);
                })
                    : Center(child: Text("No posts"),))),
        onWillPop: _backPressed);
  }

  List<Widget> buildVideoImages(PostObject? document) {
    List<Widget> listWidget = [];
    for (int i = 0; i < document!.imageList!.length; i++) {
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
                        placeholder: (context, url) => Center(
                          child: Container(
                            child: CupertinoActivityIndicator(),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                            alignment: Alignment.center,
                          ),
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
                  document.imageList!.length > 1
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 5, top: 3, bottom: 3, right: 5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFCA913B)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                color: Color(0xFF646460)),
                            margin: EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              (i + 1).toString() +
                                  " / " +
                                  document.imageList!.length.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-medium",
                                  fontSize: 10),
                            ),
                          ),
                        )
                      : Container()
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
                  ),
                  document.imageList!.length > 1
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 5, top: 3, bottom: 3, right: 5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFCA913B)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                color: Color(0xFF646460)),
                            margin: EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              (i + 1).toString() +
                                  " / " +
                                  document.imageList!.length.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins-medium",
                                  fontSize: 10),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ));
    }
    return listWidget;
  }

  Widget getPost(PostObject? document) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    profileimage!.length > 0
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
                            imageUrl: profileimage!,
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
                    document!.location!.length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                firstname!,
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.safeBlockHorizontal! * 3.5,
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
                                              SizeConfig.safeBlockHorizontal! *
                                                  3,
                                          fontFamily: "Poppins-Medium",
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            firstname!,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal! * 3.5,
                                fontFamily: "Poppins-Medium",
                                color: appColorBlack),
                          ),
                  ],
                ),
                onTap: () async {},
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
            onDoubleTap: () {},
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
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        child: Image(
                          image: AssetImage("assets/images/like_default.png"),
                        ),
                        margin: EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFF646460)),
                          child: Text(
                            " " + document.liked.toString() + " ",
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
                          image: AssetImage("assets/images/heart_default.png"),
                        ),
                        margin: EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFFE91E63)),
                          child: Text(
                            " " + document.favourite.toString() + " ",
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
                          image: AssetImage("assets/images/star_default.png"),
                        ),
                        margin: EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFFCA913B)),
                          child: Text(
                            " " + document.shared.toString() + " ",
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
                          image:
                              AssetImage("assets/images/forward-default.png"),
                        ),
                        margin: EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFF000000)),
                          child: Text(
                            " " + document.shared.toString() + " ",
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
                          image:
                              AssetImage("assets/images/bookmark_default.png"),
                        ),
                        margin: EdgeInsets.only(top: 10, right: 10),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFCA913B)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              color: Color(0xFF0B4980)),
                          child: Text(
                            " " + document.shared.toString() + " ",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      )
                    ],
                  ),
                )
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
                              document.totalLikedCount> 1
                                  ? TextSpan(
                                      text: (document.totalLikedCount - 1)
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
      ),
      color: Colors.white,
    );
  }

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
