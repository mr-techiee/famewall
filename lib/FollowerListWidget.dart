import 'dart:async';
import 'dart:developer';

import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global.dart';

class FolloweListWidget extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<FolloweListWidget>
    with TickerProviderStateMixin {
  TextEditingController controller = new TextEditingController();

  /*bool isLoading = false;
  int limit = 10;*/
  //ScrollController listScrollController = ScrollController();
  FocusNode focus = new FocusNode();
  RegExp exp = new RegExp(r"\B#\w\w+");
  StreamSubscription? streamSubscription = null;
  List<SearchObject> followersList = [];
  List<SearchObject> followingList = [];
  BaseApiService baseApiService = NetworkApiService();
  ScrollController? scrollController;
  ScrollController? followingController;
  bool? isLoading = false;
  bool? isLoading1 = false;
  int? pageNumber = 1;
  int? pageNumber1 = 1;
  TabController? _tabController;
  bool isFirstTime=false;
  String userId="";
  String firstName="";
  UserResponse? userResponse;
@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    print("didChangeDependencies");

    print(context.widget.toString());
  }
  void getArgs(){
    if(!isFirstTime){
      isLoading = false;
     isLoading1 = false;
      pageNumber = 1;
      pageNumber1 = 1;
      followersList.clear();
      followingList = [];
      isFirstTime=true;
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      print((arguments["uObject"] as UserResponse).firstname);
      userResponse=arguments["uObject"];
      userId=arguments["userId"];
      firstName=arguments["firstName"];
      log("userId");
      log(userId);
      currentTabPos=1;
      getFollowerListApi();
      getFollowingListApi();

      streamSubscription = eventBus.on<ApiResponse>().listen((event) {
        //LoadingUtils.instance.hideOpenDialog();
        if (event.status == Status.COMPLETED) {
          if (event.data is SearchList) {
            isLoading = false;
            // followersList=[];
            var postList = event.data as SearchList;
            if (!postList.iserror!) {
              print("followerSize");
              print(postList.storyList.length);
              if(pageNumber==1){
                followersList.clear();
              }
              followersList.addAll(postList.storyList);
              if(mounted){
                setState(() {});
              }
            } else {
              LoadingUtils.instance.showToast(postList.message);
            }
          } else if (event.data is FollowingList) {
            isLoading1 = false;
            // followersList=[];
            var postList = event.data as FollowingList;
            if (!postList.iserror!) {
              if(pageNumber1==1){
                followingList.clear();
              }
              followingList.addAll(postList.storyList);
              if(mounted){
                setState(() {});
              }
            } else {
              LoadingUtils.instance.showToast(postList.message);
            }
          }
        }
      });
    }

  }
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    scrollController = ScrollController()..addListener(_scrollListener);
    followingController = ScrollController()
      ..addListener(_followingScrollListener);

  }

  void _onFocusChange() {
    print("Focus: " + focus.hasFocus.toString());
  }


  @override
  void dispose() {
    focus.dispose();
    _tabController!.dispose();
    scrollController!.removeListener(_scrollListener);
    followingController!.removeListener(_followingScrollListener);
    streamSubscription!.cancel();
    super.dispose();
  }

  void _followingScrollListener() {
    print(followingController!.position.extentAfter);
    if (followingController!.position.maxScrollExtent ==
        followingController!.offset) {
      if (followingList.length >= (10 * pageNumber1!) && !isLoading1!) {
        pageNumber1 = (pageNumber1! + 1)!;
        isLoading1 = true;
        print("loadMore");
        getFollowingListApi();
      }
    }
  }

  void _scrollListener() {
    print(scrollController!.position.extentAfter);
    if (scrollController!.position.maxScrollExtent ==
        scrollController!.offset) {
      if (followersList.length >= (10 * pageNumber!) && !isLoading!) {
        pageNumber = (pageNumber! + 1)!;
        isLoading = true;
        print("loadMore");
        getFollowerListApi();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    getArgs();
    return Scaffold(appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        firstName!=null?firstName!:"",
        style: TextStyle(
            fontFamily: "Poppins-bold",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: appColorBlack,
          )),
    ),
        backgroundColor: Colors.white,
        body: Container(
          child: Column(
            children: [
              Container(
                child: TabBar(
                  indicatorColor: Color(0xFFC4861A),
                  tabs: [
                    Tab(
                      child: Stack(
                        children: [
                          Container(
                            child: Text(
                              followersList.length.toString() +
                                  " " +
                                  "Followers",
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            margin: EdgeInsets.only(top: 20),
                          )
                        ],
                      ),
                    ),
                    Tab(
                      child: Stack(
                        children: [
                          Container(
                            child: Text(
                              followingList.length.toString() +
                                  " " +
                                  "Following",
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            margin: EdgeInsets.only(top: 20),
                          )
                        ],
                      ),
                    ),
                  ],
                  controller: _tabController,
                ),
              ),
              Expanded(
                  child: TabBarView(controller: _tabController,
                      children: [
                        getFollowerList(),
                        getFollowingList()]))
            ],
          ),
        ));
  }

  Widget getFollowerList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: followersList?.length,
        controller: scrollController,
        itemBuilder: (context, position) {
          return postDetails(followersList![position], position);
        });
  }

  Widget getFollowingList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: followingList?.length,
        controller: followingController,
        itemBuilder: (context, position) {
          return followingPostDetails(followingList![position], position);
        });
  }

  Widget postDetails(SearchObject? document, pos) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () async{
              streamSubscription!.pause();
              final v= await Navigator.of(context).pushNamed(HomeWidgetRoutes.screen2,arguments: {
                "uObject":userResponse,"searchObject":document
              });
              streamSubscription!.resume();
              print("followedResume");
              isFirstTime=false;
              getArgs();
              /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(
                          userResponse: widget.userResponse,
                          searchObject: document,
                        )),
              );*/
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
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Row(
                children: <Widget>[
                  document!.profileimage!.length > 0
                      ? CircleAvatar(
                          radius: 24,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(document.profileimage!),
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
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          document.username!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 4,
                              fontFamily: "Poppins-Medium",
                              color: Colors.black),
                        ),
                      ),
                      Container(
                        child: Text(
                          document.email!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 3,
                              fontFamily: "Poppins-Medium",
                              color: Colors.grey),
                        ),
                      )
                    ],
                  )),
                  document.is_followed!.toLowerCase() == "no"
                      ? Container(
                          child: ElevatedButton(
                            onPressed: () {
                              followersList![pos].is_followed = "yes";
                              followUser(document.userid!);
                              setState(() {});
                            },
                            child: Text(
                              "Follow",
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.white,
                                  fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFFC4861A)),
                          ),
                          margin: EdgeInsets.only(left: 5, right: 5),
                        )
                      : InkWell(
                          onTap: () {
                            followersList![pos].is_followed = "no";
                            unfollowUser(document.userid!);
                            setState(() {});
                          },
                          child: Container(
                            child: Text(
                              "Unfollow",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.black,
                                  fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //                 <--- border radius here
                                  ),
                            ),
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(left: 2, right: 10),
                          ),
                        ),
                ],
              ),
            ),
          ),
          Divider(),
          Container(
            height: 2,
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 5),
    );
  }

  Widget followingPostDetails(SearchObject? document, pos) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () async{
              streamSubscription!.pause();
              final v= await Navigator.of(context).pushNamed(HomeWidgetRoutes.screen2,arguments: {
                "uObject":userResponse,"searchObject":document
              });
              streamSubscription!.resume();
              print("followedResume");
              isFirstTime=false;
              getArgs();
            /*  Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(
                          userResponse: widget.userResponse,
                          searchObject: document,
                        )),
              );*/
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
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Row(
                children: <Widget>[
                  document!.profileimage!.length > 0
                      ? CircleAvatar(
                          radius: 24,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(document.profileimage!),
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
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          document.username==""?document.firstname!:document.username!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 4,
                              fontFamily: "Poppins-Medium",
                              color: Colors.black),
                        ),
                      ),
                      Container(
                        child: Text(
                          document.email!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 3,
                              fontFamily: "Poppins-Medium",
                              color: Colors.grey),
                        ),
                      )
                    ],
                  )),
                  document.is_followed!.toLowerCase() == "no"
                      ? Container(
                          child: ElevatedButton(
                            onPressed: () {
                              followingList![pos].is_followed = "yes";
                              followUser(document.userid!);
                              setState(() {});
                            },
                            child: Text(
                              "Follow",
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.white,
                                  fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFFC4861A)),
                          ),
                          margin: EdgeInsets.only(left: 5, right: 5),
                        )
                      : InkWell(
                          onTap: () {
                            followingList![pos].is_followed = "no";
                            unfollowUser(document.userid!);
                            setState(() {});
                          },
                          child: Container(
                            child: Text(
                              "Unfollow",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.black,
                                  fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //                 <--- border radius here
                                  ),
                            ),
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.only(left: 2, right: 10),
                          ),
                        ),
                ],
              ),
            ),
          ),
          Divider(),
          Container(
            height: 2,
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 5),
    );
  }

  getFollowingListApi() {
    baseApiService.getResponse(
        "following/list/"+userId+"?perpage=10&page=" + pageNumber1.toString(),
        Status.FOLLOWING_LIST);
  }

  getFollowerListApi() {
    baseApiService.getResponse(
        "follower/list/"+userId+"?perpage=10&page=" + pageNumber.toString(),
        Status.FOLLOWERLIST);
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
