import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/Utils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:famewall/postRepository/PostListVM.dart';
import 'package:famewall/postRepository/PostMain.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

import '../global.dart';

class NotificationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationWidgetState();
  }
}

class NotificationWidgetState extends State<NotificationWidget> {
  bool show = false;
  final PostListVM viewModel = PostListVM();
  List<NotificationObject> postList = [];
  BaseApiService baseApiService = NetworkApiService();
  ScrollController? controller;
  bool? isLoading = false;
  int? pageNumber = 1;
  StreamSubscription? streamSubscription = null;
  bool isShowTrend=true;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
    isLoading = false;
    pageNumber = 1;
    postList = [];
    getPostList();
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        if (event.data is NotificationList) {
          isLoading = false;
          var nList = event.data as NotificationList;
          if (!nList.iserror!) {
            postList!.addAll(nList.followerVideoList);
            if(mounted){
              setState(() {});
            }
          } else {
            LoadingUtils.instance.showToast(nList.message);
          }
        }
      }
    });
    //viewModel.fetchPost();
  }

  void _scrollListener() {
    print(controller!.position.extentAfter);
    if (controller!.position.maxScrollExtent == controller!.offset) {
      if (postList.length >= (10 * pageNumber!) && !isLoading!) {
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
  void getPostList() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse(
          "mynotifications",
          Status.NOTIFICATION_LIST);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,leading: Container(),
          title: Container(
            child: Text("Notification", style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold,  fontFamily: "Poppins-medium",
                fontSize: 14),), margin: EdgeInsets.only(right: 5),),
          elevation: 0,),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Divider(),

          postList.length>0?Expanded(child: _getMoviesListView(
              postList!)):Center(child: Container(margin: EdgeInsets.only(top: 50),child: Text("No new activities found.\nInvite you’re friends to Famewal!",textAlign: TextAlign.center,),),),
        ],),
        /*ChangeNotifierProvider<PostListVM>(
       create: (BuildContext context) => viewModel,
       child: Consumer<PostListVM>(builder: (context, viewModel, _) {
         switch (viewModel.movieMain.status) {
         */ /*  case Status.LOADING:
             print("MARAJ :: LOADING");
             return LoadingWidget();
           case Status.ERROR:
             print("MARAJ :: ERROR");
             return MyErrorWidget(viewModel.movieMain.message ?? "NA");*/ /*
           case Status.COMPLETED:
             print("MARAJ :: COMPLETED");
             return _getMoviesListView(viewModel.movieMain.data?.movies);
           default:
         }
         return Container();
       }),
     )*/

      ),
    );
  }

  Widget _getMoviesListView(List<NotificationObject>? moviesList) {
    return ListView.builder(shrinkWrap: true,
        itemCount: moviesList?.length,
        itemBuilder: (context, position) {

          return postDetails(moviesList![position]);
        });
  }

  Widget postDetails(NotificationObject? document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () {
            if(document!.notificationtype=="post-like"||document!.notificationtype=="post-unlike"){
              Navigator.of(context)
                  .pushNamed(HomeWidgetRoutes.screen9, arguments: {
                "postId": document!.postId,
                "userId": document._id,
                "firstName": document!.username,
                "profileimage": document!.profileimage
              });
            }
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
                  backgroundColor: Color(0xFFC4861A),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(document.profileimage!),
                    radius: 22,
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border:
                      Border.all(color: appColorBlack, width: 0.5),
                      shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFC4861A),
                      child: CircleAvatar(
                        backgroundImage:
                        AssetImage('assets/images/name.png'),
                        radius: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Expanded(child: Container(
                  child: Row(children: [
                    Text(
                      document.username, style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 3.5,
                        fontFamily: "Poppins-bold",
                        color: Colors.black),
                    ),
                    Text(
                      document.message, style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 3.5,
                        fontFamily: "Poppins-Medium",
                        color: Colors.black),
                    )
                  ],),

                )),
                /*Container(
                  child: ElevatedButton(
                    onPressed: () {

                    },
                    child: Text(
                      "Follow",
                      style: TextStyle(  fontFamily: "Poppins-medium",
                          color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFC4861A)),
                  ),

                  margin: EdgeInsets.only(
                      left: 5, right: 5),
                ),*/
              ],
            ),
          ),
        ),
        Container(
          height: 2,
        ),
        Divider(thickness: 0.3, color: selectedTabColor,)
      ],
    );
  }
}

class NotificationObject{
  String filepath="";
  String _id="";
  String firstname="";
  String username="";
  String email="";
  String profileimage="";
  String postId="";
  String notifyuserid="";
  String notificationtype="";
  String createdon="";
  String message="";
}
class NotificationList {
  bool? iserror = false;
  String? message = "";
  List<NotificationObject> followerVideoList = [];

  NotificationList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          NotificationObject postObject = NotificationObject();
          postObject.notificationtype = list[i]["notificationtype"];
          if(list[i]["notificationtype"]=="post-like"){
            postObject.message=" is liked your post";
          }else if(list[i]["notificationtype"]=="post-unlike"){
            postObject.message=" is unliked your post";
          }else if(list[i]["notificationtype"]=="follow"){
            postObject.message=" is following you";
          }
          postObject.createdon = list[i]["createdon"];
          postObject.firstname = list[i]["createdby"]["firstname"];
          postObject.username = list[i]["createdby"]["username"];
          postObject.email = list[i]["createdby"]["email"];
          postObject.profileimage = list[i]["createdby"]["profileimage"];
          postObject._id = list[i]["createdby"]["_id"];
          postObject.postId = list[i]["postid"]!=null?list[i]["postid"]["_id"]:"";
          followerVideoList.add(postObject);
        }
      }
    }
  }
}
