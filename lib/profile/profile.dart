import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/LoginScreen.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/profile/editprofile1.dart';
import 'package:famewall/story/GridVideoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import '../FollowerListWidget.dart';
import '../PrefUtils.dart';
import '../Utils.dart';
import '../WebviewWidget.dart';
import '../global.dart';
import '../helper/sizeConfig.dart';
import 'HomeRoutes.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  List newProjectList = [];

  bool isInView = false;
  List<Widget> myTabs = [];
  List<UserStory> userStoryList = [];
  List<UserStory> userPostsList = [];
  List<UserStory> userVideosList = [];
  String totalPost = '0';
  TabController? _tabController;
  BaseApiService baseApiService = NetworkApiService();
  StreamSubscription? streamSubscription = null;
  UserResponse? userResponse;
  int viewPos = 0;
  bool isMySelf = false;
  bool isFirstTime = false;
  PostObject? postObject;
  SearchObject? searchObject;

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
    userResponse = arguments["uObject"];
    postObject = arguments["postObject"];
    searchObject = arguments["searchObject"];
    if (postObject != null) {
      print("postObject!.firstname!");
      print(postObject!.firstname!);
      firstname = postObject!.firstname!;
      userId = postObject!.userid!;
      lastname = postObject!.lastname!;
      email = postObject!.email!;
      followingcount = postObject!.following!;
      followercount = postObject!.follower!;
      username = postObject!.username!;
      profileimage = postObject!.profileimage!;
      bio = postObject!.bio!;
      website = postObject!.website!;
      print("postObject!.firstname!");
      print(userResponse!.username!);
    } else if (searchObject != null) {
      firstname = searchObject!.firstname!;
      userId = searchObject!.userid!;
      lastname = searchObject!.lastname!;
      username = searchObject!.username!;

      email = searchObject!.email!;
      followingcount = searchObject!.following;
      followercount = searchObject!.follower!;
      //userResponse!.username = searchObject!.username!;
      profileimage = searchObject!.profileimage!;
      bio = searchObject!.bio!;
      website = searchObject!.website!;
      print("postObject!.firstname!");
      print(userResponse!.username!);
    } else {
      firstname = userResponse!.firstname!;
      lastname = userResponse!.lastname!;
      email = userResponse!.email!;
      followingcount = userResponse!.followingcount!;
      followercount = userResponse!.followercount!;
      username = userResponse!.username!;
      profileimage = userResponse!.profileimage!;
      bio = userResponse!.bio!;
      website = userResponse!.website!;
      userId = userResponse!.userId!;
      username = userResponse!.username;
    }

    getProfileData();
    _tabController = new TabController(length: 3, vsync: this);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is UserResponse) {
          var postList = event.data as UserResponse;
          if (!postList.iserror!) {
            userResponse = postList;
            firstname = userResponse!.firstname!;
            lastname = userResponse!.lastname!;
            email = userResponse!.email!;
            followingcount = userResponse!.followingcount!;
            followercount = userResponse!.followercount!;
            username = userResponse!.username!;
            profileimage = userResponse!.profileimage!;
            bio = userResponse!.bio!;
            website = userResponse!.website!;
            userId = userResponse!.userId!;
            if (mounted) {
              setState(() {});
            }
          } else {
            // LoadingUtils.instance.showToast(postList.message);
          }
        } else if (event.data is UserStoryList) {
          userStoryList = [];
          var postList = event.data as UserStoryList;
          userStoryList.addAll(postList.storyList);
          if (mounted) {
            setState(() {});
          }
        } else if (event.data is UserPostList) {
          userPostsList = [];
          userVideosList = [];
          var postList = event.data as UserPostList;
          if (postList.storyList.length > 0) {
            userPostsList.addAll(postList.storyList);
            userVideosList.addAll(postList.videoStoryList);
          }

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
  }

  void getProfileData() {
    Future.delayed(Duration(seconds: 1), () {
      String userId =
          postObject == null ? userResponse!.userId! : postObject!.userid!;
      if (searchObject != null) {
        userId = searchObject!.userid!;
      }
      if ((postObject != null && postObject!.userid == userResponse!.userId) ||
          (searchObject != null &&
              searchObject!.userid == userResponse!.userId)) {
        baseApiService.getResponse("myprofile", Status.GET_PROFILE);
        isMySelf = true;
        setState(() {});
      } else if (postObject == null && searchObject == null) {
        baseApiService.getResponse("myprofile", Status.GET_PROFILE);
        isMySelf = true;
        setState(() {});
      }
      baseApiService.getResponse(
          "files/story/" + userId, Status.GET_USER_STORY);
      baseApiService.getResponse("files/post/" + userId, Status.GET_USER_POST);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
    streamSubscription!.cancel();
  }

  void sendEmail() async {
    final Email email = Email(
      body: '',
      subject: 'Famewall',
      recipients: [userResponse!.email!],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  void settingView() {
    print("settingView");
    PopupMenuButton(
      child: Center(child: Text('click here')),
      itemBuilder: (context) {
        return List.generate(5, (index) {
          return PopupMenuItem(
            child: Text('button no $index'),
          );
        });
      },
    );
  }
  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel",style:TextStyle(color: Color(0xffC4861A),)),
      onPressed:  () {
        Navigator.of(context!, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text("Logout",style:TextStyle(color: Color(0xffC4861A),)),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        PreferenceUtils.setBool("is_login", false);
        //Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushNamedAndRemoveUntil(context,HomeWidgetRoutes.screen18, (route) => false
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Are you sure? You want to logout?",),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
                    username!,
                    style: TextStyle(
                        fontFamily: "Poppins-bold",
                        fontSize: 18,
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
                  actions: [
                    /*IconButton(
                        onPressed: () {
                          settingView();
                        },
                        icon: Icon(
                          Icons.settings,
                          color: appColorBlack,
                        ))*/
                    PopupMenuButton(offset: Offset(0,30),onSelected: (_){
                      log("logout");
                      log(_.toString());
                      if(_.toString() == "Logout"){
                        print("logout");
                       showAlertDialog(context);
                      }
                    },
                      shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffC4861A)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Container(
                          child: Icon(
                        Icons.settings,
                        color: appColorBlack,
                      ),margin: EdgeInsets.only(right: 10),),
                      itemBuilder: (context) {
                        return <PopupMenuItem<String>>[
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Setting"),flex: 9,), Icon(Icons.settings,color: appColorBlack,)],), value: 'Doge'),
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Privacy")),Icon(Icons.privacy_tip,color: appColorBlack,)],), value: 'Doge'),
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Account")),Icon(Icons.supervisor_account,color: appColorBlack,)],), value: 'Doge'),
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Help")),Icon(Icons.help,color: appColorBlack,)],), value: 'Doge'),
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Invite Friends")),Image(image: AssetImage("assets/images/user-add.png"),height: 20,width: 20,)],), value: 'Doge'),
                          new PopupMenuItem<String>(
                              child:Row(children: [Expanded(child: Text("Logout")),Icon(Icons.logout,color: appColorBlack,)],), value: 'Logout'),

                        ];
                      },
                    )
                  ],
                ),
                body: SingleChildScrollView(
                  primary: true,
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                profileimage!.isNotEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xFFCA913B),
                                                width: 1),
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(profileimage!),
                                            radius: 45,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xFFCA913B),
                                                width: 1),
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundImage: AssetImage(
                                                'assets/images/name.jpg'),
                                          ),
                                        ),
                                      ),
                                InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              firstname!,
                                              style: TextStyle(
                                                  fontFamily: "Poppins-medium",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Container(
                                            constraints: new BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    180),
                                            child: Flexible(
                                              child: Text(
                                                bio!,
                                                style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-medium",
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            child: Container(
                                              child: Text(
                                                website!,
                                                style: TextStyle(
                                                    fontFamily:
                                                        "Poppins-medium",
                                                    color: Color(0xFF3797EF),
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            onTap: () {
                                              if (!Utils.isEmpty(website!)) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WebViewWidget(
                                                            webUrl: website,
                                                          )),
                                                );
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    streamSubscription!.pause();
                                    /*viewPos=1;
                            setState(() {

                            });*/
                                    final v = await Navigator.of(context)
                                        .pushNamed(HomeWidgetRoutes.screen3,
                                            arguments: {
                                          "userId": userId,
                                          "firstName": username,
                                          "uObject": userResponse
                                        });
                                    streamSubscription!.resume();
                                    isFirstTime = false;
                                    getArguments();
                                  },
                                  child: _buildCategory(
                                      "Followers", followercount!.toString()),
                                ),
                                InkWell(
                                    onTap: () async {
                                      streamSubscription!.pause();
                                      final v = await Navigator.of(context)
                                          .pushNamed(HomeWidgetRoutes.screen3,
                                              arguments: {
                                            "userId": userId,
                                            "firstName": username,
                                            "uObject": userResponse
                                          });
                                      streamSubscription!.resume();
                                      isFirstTime = false;
                                      getArguments();
                                    },
                                    child: _buildCategory("Following",
                                        followingcount!.toString())),
                                Row(
                                  children: [
                                    Container(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if ((postObject == null &&
                                                  searchObject == null) ||
                                              (postObject != null &&
                                                  postObject!.userid ==
                                                      userResponse!.userId) ||
                                              (searchObject != null &&
                                                  searchObject!.userid ==
                                                      userResponse!.userId)) {
                                            streamSubscription!.pause();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfile(
                                                          userResponse:
                                                              userResponse)),
                                            ).then((value) => {
                                                  streamSubscription!.resume(),
                                                  getProfileData()
                                                });
                                          } else {
                                            if (postObject != null) {
                                              if (postObject!.is_followed ==
                                                  "yes") {
                                                postObject!.is_followed = "no";
                                                unfollowUser(
                                                    postObject!.userid!);
                                              } else {
                                                postObject!.is_followed = "yes";
                                                followUser(postObject!.userid!);
                                              }
                                            } else if (searchObject != null) {
                                              if (searchObject!.is_followed ==
                                                  "yes") {
                                                searchObject!.is_followed =
                                                    "no";
                                                unfollowUser(
                                                    searchObject!.userid!);
                                              } else {
                                                searchObject!.is_followed =
                                                    "yes";
                                                followUser(
                                                    searchObject!.userid!);
                                              }
                                            }
                                            setState(() {});
                                          }
                                        },
                                        child: Text(
                                          (postObject == null &&
                                                      searchObject == null) ||
                                                  (postObject != null &&
                                                      postObject!.userid ==
                                                          userResponse!
                                                              .userId) ||
                                                  (searchObject != null &&
                                                      searchObject!.userid ==
                                                          userResponse!.userId)
                                              ? "Edit Profile"
                                              : postObject != null
                                                  ? postObject!.is_followed ==
                                                          "yes"
                                                      ? "Followed"
                                                      : "Follow"
                                                  : searchObject!.is_followed ==
                                                          "yes"
                                                      ? "Followed"
                                                      : "Follow",
                                          style: TextStyle(
                                              fontFamily: "Poppins-medium",
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Color(0xFFC4861A)),
                                      ),
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                    ),
                                    Container(
                                      child: Image(
                                        image: AssetImage(
                                            "assets/images/add_user.png"),
                                      ),
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          !isMySelf
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          if (userId != null &&
                                              username != null) {
                                            final peerName = username!.isEmpty
                                                ? "${searchObject?.username} ${searchObject?.lastname}"
                                                : username;
                                            Navigator.of(context).pushNamed(
                                              HomeWidgetRoutes.screen14,
                                              arguments: {
                                                "peerId": userId!,
                                                "peerName": peerName,
                                                "profileImage": profileimage!,
                                              },
                                            );
                                          }
                                        },
                                        child: Container(
                                            child: Text("Message",
                                                textAlign: TextAlign.center),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.0,
                                                  color: Color(0xFFCA913B)),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      5.0) //                 <--- border radius here
                                                  ),
                                            ),
                                            padding: EdgeInsets.all(8),
                                            margin: EdgeInsets.only(
                                                left: 2, right: 2)),
                                      )),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          sendEmail();
                                        },
                                        child: Container(
                                          child: Text("Contact",
                                              textAlign: TextAlign.center),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: Color(0xFFCA913B)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.only(
                                              left: 2, right: 2),
                                        ),
                                      )),
                                    ],
                                  ),
                                )
                              : Container(),
                          /*   Container(
                    child: storyListView(),
                    height: 100,
                  ),*/
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      isMySelf
                          ? Container(
                              width: 250,
                              child: TabBar(
                                indicatorColor: Color(0xFFC4861A),
                                tabs: [
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Posts",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " +
                                                  userPostsList.length
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Videos",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " +
                                                  userVideosList.length
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Stories",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " +
                                                  userStoryList.length
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                                controller: _tabController,
                              ),
                            )
                          : Container(
                              width: 250,
                              child: TabBar(
                                indicatorColor: Color(0xFFC4861A),
                                tabs: [
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Posts",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " +
                                                  userPostsList.length
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Videos",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " +
                                                  userVideosList.length
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Text(
                                            "Tagged",
                                            style: TextStyle(
                                                fontFamily: "Poppins-medium",
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                          margin: EdgeInsets.only(top: 20),
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
                                                color: Colors.transparent),
                                            child: Text(
                                              " " + "0" + " ",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                                controller: _tabController,
                              ),
                            ),
                      Container(
                        child: isMySelf
                            ? Expanded(
                                child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  _userPostInfo(),
                                  userPostVideoInfo(),
                                  _userInfo(),
                                ],
                                controller: _tabController,
                              ))
                            : Expanded(
                                child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  _userPostInfo(),
                                  userPostVideoInfo(),
                                  Container(),
                                ],
                                controller: _tabController,
                              )),
                        height: MediaQuery.of(context).size.height - 300,
                      )
                    ],
                  ),
                ))),
        onWillPop: _backPressed);
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

  Widget storyListView() {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: userStoryList.length,
        itemBuilder: (context, position) {
          return InkWell(
            child: Container(
              child: Column(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Color(0xFFC4861A))),
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(userStoryList[position].filepath!),
                      radius: 34,
                    ),
                  ),
                  Container(
                    child: Text(
                      "Test",
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal! * 3.5,
                        color: appColorBlack,
                        fontFamily: "Poppins-medium",
                      ),
                    ),
                    margin: EdgeInsets.only(top: 5),
                  )
                ],
              ),
              margin: EdgeInsets.only(left: 10),
            ),
            onTap: () {},
          );
        });
  }

  Widget _buildCategory(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
              fontFamily: "Poppins-medium",
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: appColorBlack),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
              fontFamily: "Poppins-medium",
              color: appColorBlack,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
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

  Widget _userPostInfo() {
    return Container(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
          itemCount: userPostsList.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            return userPostsList[position].isImage!
                ? InkWell(
                    child: Stack(
                      children: [
                        Positioned(
                            child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: CachedNetworkImage(
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
                            imageUrl: userPostsList[position].filepath!,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 35.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            // width: 35.0,
                            // height: 35.0,
                            fit: BoxFit.cover,
                          ),
                          margin: EdgeInsets.only(left: 3, top: 3),
                        )),
                        Positioned(
                          child: userPostsList[position].isMultiple!
                              ? Container(
                                  child: Icon(
                                    Icons.my_library_add,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                )
                              : Container(),
                          top: 5,
                          right: 5,
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(HomeWidgetRoutes.screen9, arguments: {
                        "postId": userPostsList[position].id,
                        "userId": userId,
                        "firstName": username,
                        "profileimage": profileimage
                      });
                    },
                  )
                : Container(
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: GridVideoView(
                            url: userPostsList[position].filepath!,
                            play: false,
                            isMute: false,
                            id: userPostsList[position].id,
                            firstName: username,
                            profileImage: profileimage,
                            isPost: true,
                          ),
                        ),
                        Positioned(
                          child: userPostsList[position].isMultiple!
                              ? Container(
                                  child: Icon(
                                    Icons.my_library_add,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                )
                              : Container(),
                          top: 5,
                          right: 1,
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(left: 3, top: 3),
                  );
          }),
    );
  }

  Widget userPostVideoInfo() {
    return Container(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
          itemCount: userVideosList.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            return InkWell(
              child: Container(
                child: Stack(
                  children: [
                    InkWell(
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: GridVideoView(
                          url: userVideosList[position].filepath!,
                          play: false,
                          isMute: false,
                          id: userVideosList[position].id,
                          firstName: username,
                          profileImage: profileimage,
                          isPost: true,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(HomeWidgetRoutes.screen9, arguments: {
                          "postId": userVideosList[position].id,
                          "firstName": username,
                          "profileimage": profileimage
                        });
                      },
                    ),
/*
                  Positioned(child: userVideosList[position].isMultiple!?Container(child: Icon(Icons.my_library_add,color: Colors.white,size: 18,),):Container(),top: 5,right: 1,)
*/
                  ],
                ),
                margin: EdgeInsets.only(left: 3, top: 3),
              ),
              onTap: () {
                print("yes");
                Navigator.of(context)
                    .pushNamed(HomeWidgetRoutes.screen9, arguments: {
                  "postId": userVideosList[position].id,
                  "firstName": username,
                  "profileimage": profileimage
                });
              },
            );
          }),
    );
  }

  Future<File> _generateThumbnail(path) async {
    final String? _path = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,

      /// path_provider
      imageFormat: ImageFormat.PNG,
      maxHeight: 50,
      quality: 50,
    );
    return File(_path!);
  }

  Widget _userInfo() {
    return Container(
      padding: EdgeInsets.all(10),
      child: GridView.builder(
          itemCount: userStoryList.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, position) {
            return userStoryList[position].isImage!
                ? InkWell(
                    child: Container(
                      child: CachedNetworkImage(
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
                        imageUrl: userStoryList[position].filepath!,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 35.0,
                          height: 35.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        // width: 35.0,
                        // height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(left: 3, top: 3),
                    ),
                    onTap: () {
                      print("filePath");
                      print(userStoryList[position].filepath);

                      Navigator.of(context)
                          .pushNamed(HomeWidgetRoutes.screen10, arguments: {
                        "isImage": userStoryList[position].isImage,
                        "filePath": userStoryList[position].filepath,
                        "userName": username,
                        "profileImage": profileimage
                      });
                    },
                  )
                : Container(
                    child: Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: GridVideoView(
                              url: userStoryList[position].filepath!,
                              play: false,
                              isMute: false,
                              isPost: false,
                              firstName: username,
                              profileImage: profileimage),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 3, top: 3),
                  );
          }),
    );
  }

  void followUser(String id) {
    var request = {'following_userid': id};
    print("request");

    baseApiService.postResponse("follow/add", request, Status.FOLLOW);
  }

  void unfollowUser(String id) {
    baseApiService.deleteResponse("unfollow/" + id, Status.FOLLOW);
  }
}
