import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:famewall/WebviewWidget.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/story/AddStoryWidget.dart';
import 'package:famewall/pinch_zoom_image.dart';
import 'package:famewall/postRepository/PostListVM.dart';
import 'package:famewall/profile/profile.dart';
import 'package:famewall/search/search_new.dart';
import 'package:famewall/videoView.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import 'BubbleWidget.dart';
import 'PostScreen.dart';
import 'PrefUtils.dart';
import 'StoryWidget.dart';
import 'TrianglePath.dart';
import 'Utils.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';
import 'global.dart';
import 'helper/sizeConfig.dart';
import 'dart:math' as math;
class HomeWidget extends StatefulWidget {
   bool isUpdated=false;
  @override
  State<StatefulWidget> createState() {
    return HomeScreenWidgetState();
  }

}

class HomeScreenWidgetState extends State<HomeWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool show = false;
  int showPos = 0;
  int selectedPostPos = 0;
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
  void didUpdateWidget(covariant HomeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("oldWidget");
  }

  void getPostList() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse(
          "allposts?perpage=10&page=" + pageNumber!.toString(),
          Status.POST_LIST);
    });
  }

  void getStoryList() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse("story/list", Status.STORY_LIST);
      baseApiService.getResponse("allstories", Status.ALL_STORY_LIST);
    });
  }

  void getProfileData() {
    Future.delayed(Duration.zero, () {
      baseApiService.getResponse("myprofile", Status.GET_PROFILE);
    });
  }
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
  late final FirebaseMessaging _messaging;
  late int _totalNotifications;
  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

      /*  // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );*/

        setState(() {
         /* _notificationInfo = notification;
          _totalNotifications++;*/
        });

       /* if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }*/
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
  void getFcmToke() async {
    print("requesfcm");
    final fcmToken=await FirebaseMessaging.instance.getToken();
    print(fcmToken);
    var request = {
      'userid': userResponse!.userId!,
      'fcmtoken': fcmToken.toString(),
    };
    print("fcmToken");
    print(request);
    baseApiService.postResponse("updateFCMToken",request, Status.FOLLOW);
  }

  @override
  void initState() {
    super.initState();
    registerNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.data.toString());
     /* PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });*/
    });
    getStoryList();
    controller = ScrollController()..addListener(_scrollListener);
    isLoading = false;
    pageNumber = 1;
    postLists = [];
    postLists.add(PostObject());
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

    /*streamSubscription = eventBus.on<int>().listen((event) {
      if (event == 1) {
        viewPos = 0;
        setState(() {});
      }
    });*/
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
      if(event.status==Status.REFRESH){
        print("refresh");
        controller!.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
        isShowTrend=true;
        setState(() {

        });
        return;
      }
      if (event.status == Status.COMPLETED) {
        if (event.data is PostList) {
          isLoading = false;
          var postList = event.data as PostList;
          if (!postList.iserror!) {
            postLists.addAll(postList.postList);
            setState(() {});
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        }
        if (event.data is StoryList) {
          var postList = event.data as StoryList;
          myStoryList = [];
          if (!postList.iserror!) {
            myStoryList.addAll(postList.storyList);
            setState(() {});
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        } else if (event.data is UserResponse) {
          var postList = event.data as UserResponse;
          if (!postList.iserror!) {
            userResponse = postList;
            _userResponse = postList;
            PreferenceUtils.setString("userId",userResponse!.userId!);
            print(userResponse!.userId!);
            print("userResponse");
            getFcmToke();
            setState(() {});
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        } else if (event.data is AllStoryList) {
          var postList = event.data as AllStoryList;
          allStoriesList = [];
          allStoriesList.add(AllStoryMainObject());
          if (!postList.iserror!) {
            allStoriesList.addAll(postList.storyMainList);
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
    postLists.add(PostObject());
    getPostList();
    // why use freshWords var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            floatingActionButton: viewPos == 0
                ? FloatingActionBubble(
                    // Menu items
                    items: <Bubble>[
                      // Floating action menu item
                      Bubble(
                        title: "Post",
                        iconColor: Colors.white,
                        bubbleColor: Color(0xFFC4861A),
                        icon: Icons.post_add,
                        titleStyle:
                            TextStyle(fontSize: 14, color: Colors.white),
                        onPress: () {
                          _animationController!.reverse();
                          isFab = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostScreen()),
                          ).then((value) => {
                                if (value != null) {_pullRefresh()}
                              });
                        },
                      ),
                      // Floating action menu item
                      Bubble(
                        title: "Stories",
                        iconColor: Colors.white,
                        bubbleColor: Color(0xFFC4861A),
                        icon: Icons.camera,
                        titleStyle:
                            TextStyle(fontSize: 14, color: Colors.white),
                        onPress: () async {
                          _animationController!.reverse();
                          isFab = false;
                          streamSubscription!.pause();
                          final v = await Navigator.of(context)
                              .pushNamed(HomeWidgetRoutes.screen7)
                              .then((value) => {
                                    HomeWidgetState.of(context)!
                                        .updateBottomNav(),
                                    streamSubscription!.resume(),
                                    getStoryList()
                                  });

                          /*  Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddStoryWidgetScreen()),
                          );*/
                        },
                      ),
                    ],

                    // animation controller
                    animation: _animation!,

                    // On pressed change animation state
                    onPress: () => {
                      isFab ? isFab = false : isFab = true,
                      _animationController!.isCompleted
                          ? _animationController!.reverse()
                          : _animationController!.forward(),
                      setState(() {})
                    },

                    // Floating Action button Icon color
                    iconColor: Color(0xFFC4861A),

                    // Flaoting Action button Icon
                    iconData: isFab ? Icons.close : Icons.add,
                    backGroundColor: Colors.black,
                  )
                : Container(),
            backgroundColor: Colors.white,
            appBar: viewPos == 0&&isShowTrend
                ? AppBar(bottom: PreferredSize(
                child: Container(margin: EdgeInsets.only(bottom: 5),
                  color: Colors.grey.withOpacity(0.3),
                  height: 0.5,
                ),
                preferredSize: Size.fromHeight(4.0)),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    title: SvgPicture.asset("assets/images/famewal_logo.svg"),
                    leading: Container(
                      child: Image(
                        image: AssetImage("assets/images/camera_insta.png"),
                      ),
                    ),
                    elevation: 0,
                    actions: [
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image(
                            image: AssetImage("assets/images/search_icon.png"),
                          ),
                          height: 30,
                          width: 30,
                        ),
                        onTap: () async {
                          /* viewPos = 1;
                          setState(() {});*/
                          streamSubscription!.pause();
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Profile()),
                          ).then((value) =>
                              {});*/
                          final v = await Navigator.of(context).pushNamed(
                              HomeWidgetRoutes.screen4,
                              arguments: {"uObject": userResponse});
                          streamSubscription!.resume();
                          getProfileData();
                        },
                      ),
                      InkWell(
                        child: Container(
                          child: userResponse != null &&
                                  userResponse!.profileimage!.isNotEmpty
                              ? CachedNetworkImage(
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
                                  imageUrl: userResponse!.profileimage!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 35.0,
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: Color(0xFFC4861A)),
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  // width: 35.0,
                                  // height: 35.0,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  child: CircleAvatar(
                                    radius: 14.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:
                                          Image.asset("assets/images/name.jpg"),
                                    ),
                                    backgroundColor: Color(0xFFC4861A),
                                  ),
                                ),
                          margin: EdgeInsets.only(right: 5),
                        ),
                        onTap: () async {
                          streamSubscription!.pause();
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Profile()),
                          ).then((value) =>
                              {});*/
                          final v = await Navigator.of(context).pushNamed(
                              HomeWidgetRoutes.screen2,
                              arguments: {"uObject": userResponse});
                          streamSubscription!.resume();
                          getProfileData();
                        },
                      )
                    ],
                  )
                : null,
            body: viewPos == 0
                ? RefreshIndicator(
                    child: _getMoviesListView(postLists),
                    onRefresh: _pullRefresh)
                : viewPos == 1
                    ? SearchFeed()
                    : getProfileView(),
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
        ),
        onWillPop: _backPressed);
  }

  Widget storyListView() {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: allStoriesList.length,
        itemBuilder: (context, position) {
          return InkWell(
            child: Container(
              child: Column(
                children: [
                  position == 0
                      ? Container(
                          child: userResponse != null &&
                                  userResponse!.profileimage!.isNotEmpty
                              ? CachedNetworkImage(
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
                                  imageUrl: userResponse!.profileimage!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 70.0,
                                    height: 70.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 2, color: Color(0xFFC4861A)),
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  // width: 35.0,
                                  // height: 35.0,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  child: CircleAvatar(
                                    radius: 36.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:
                                          Image.asset("assets/images/name.jpg"),
                                    ),
                                    backgroundColor: Color(0xFFC4861A),
                                  ),
                                ),
                          margin: EdgeInsets.only(right: 5),
                        )
                      : Container(
                          height: 70,
                          width: 70,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 2, color: Color(0xFFC4861A))),
                          child: allStoriesList[position]
                                  .profileimage!
                                  .isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      allStoriesList[position].profileimage!),
                                  radius: 34,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/name.jpg"),
                                  radius: 34,
                                ),
                        ),
                  Container(
                    child: Text(
                      position == 0
                          ? "Your story"
                          : allStoriesList[position].userName!,
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
            onTap: () async {
              if (position == 0) {
                if (myStoryList.length > 0) {
                  final v = await Navigator.of(context)
                      .pushNamed(HomeWidgetRoutes.screen8, arguments: {
                    "myStoryList": myStoryList,
                    "allPos": 0,
                    "userName": userResponse!.username!,
                    "profileImage": userResponse!.profileimage!
                  });
                  HomeWidgetState.of(context)!.updateBottomNav();
                  /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MoreStories(
                              myStoryList: myStoryList,
                              allPos: 0,
                              userName: userResponse!.firstname!,
                              profileImage: userResponse!.profileimage!,
                            )),
                  );*/
                }
              } else {
                final v = await Navigator.of(context)
                    .pushNamed(HomeWidgetRoutes.screen8, arguments: {
                  "allStoriesList": allStoriesList,
                  "allPos": position
                });
                HomeWidgetState.of(context)!.updateBottomNav();
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MoreStories(
                            allStoriesList: allStoriesList,
                            allPos: position,
                          )),
                );*/
              }

              /* viewPos = 2;
              setState(() {});*/
            },
          );
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
        if (position == 0) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: EdgeInsets.only(top: 5),
                  child: storyListView(),
                  height: 105,
                ),
              Container(color: Colors.grey.withOpacity(0.3),width: double.infinity,height: 0.5,)
              ],
            ),
          );
        } else {
          return postDetails(postList![position], position);
        }
      },
      separatorBuilder: (context, index) {
        return Container(margin: EdgeInsets.only(top: 10),);
      },
    );
  }

  List<Widget> buildVideoImages(PostObject document, int position) {
    List<Widget> listWidget = [];
    for (int i = 0; i < document.imageList!.length; i++) {
      listWidget.add(document.imageList![i].isImage!
          ? Stack(
              children: [
                InkWell(
                  child: Container(
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
                              imageBuilder: (context, imageProvider) =>
                                  Container(
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
                            zoomedBackgroundColor:
                                Color.fromRGBO(240, 240, 240, 1.0),
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
                                      border:
                                          Border.all(color: Color(0xFFCA913B)),
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
                  ),
                  onTap: () {
                    postLists[position].imageList![i].isShowTagged =
                        !postLists[position].imageList![i].isShowTagged;
                    setState(() {});
                  },
                ),
                postLists[position].imageList![i].isShowTagged
                    ? Container(
                        child: Stack(
                          children: getPointedWidget(
                              document.imageList![i].taggedList),
                        ),
                        height: double.infinity,
                      )
                    : Container()
              ],
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

  List<Widget> getPointedWidget(List<TaggedObject> offSetList) {
    List<Widget> list = [];
    for (int i = 0; i < offSetList.length; i++) {
      if(offSetList[i].imageposition.split(",").length>1){
        list.add(Positioned(
          top: double.parse(offSetList[i].imageposition.split(",")[1]),
          left: double.parse(offSetList[i].imageposition.split(",")[0]),
          child: Container(
            height: 50,
            child: Container(
                child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children:[
                      Container(
                          child:CustomPaint(
                            painter: TrianglePainter(
                              strokeColor: Colors.black,
                              strokeWidth: 10,
                              paintingStyle: PaintingStyle.fill,
                            ),
                            child: Container(
                              height: 10,
                              width: 20,
                            ),
                          )
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        child: Flexible(child: InkWell(child: Container(width: 80,child: Text(
                          Uri.parse(offSetList[i].taggedtext).isAbsolute?"Link":offSetList[i].taggedtext,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,style: TextStyle(color:Uri.parse(offSetList[i].taggedtext).isAbsolute?Colors.blue:Colors.white, fontSize: 12),
                        ),),onTap: (){
                          if(Uri.parse(offSetList[i].taggedtext).isAbsolute){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WebViewWidget(webUrl: offSetList[i].taggedtext,)),
                            );
                          }

                        },),),
                      )
                    ]
                )

            )/*Column(
            children: [
              Container(
                child: Image(image: AssetImage("assets/images/up_arrow.png"),height: 15,),
              ),
              InkWell(child: Container(
                padding: EdgeInsets.only(left: 15,right: 15,top: 5,bottom: 5),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Flexible(child: Container(width: 80,child: Text(
                  Uri.parse(offSetList[i].taggedtext).isAbsolute?"Link":offSetList[i].taggedtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,style: TextStyle(color: offSetList[i].taggedtext.startsWith("https")||offSetList[i].taggedtext.startsWith("http")?Colors.blue:Colors.white, fontSize: 12),
                ),),),
              ),onTap: (){

              },)
            ],
          )*/,
          ),
        ));
      }

    }
    return list;
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
                  InkWell(child: Container(child: Icon(Icons.more_horiz),margin: EdgeInsets.only(right: 10),),onTap: (){
                   showMoreOptionBottomSheet(position);
                  },)
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
                      children: buildVideoImages(document, position),
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
                  if (postLists[position].taggedList.length > 0) {
                    showTaggedListSheet(
                        postLists[position].taggedList);
                  }
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
  showTaggedListSheet(List<TaggedObject> list) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 3 + 35,
            color: Color(0x00737373),
            child: getTaggedView(list),
          );
        });
  }

  Widget getTaggedView(List<TaggedObject> list) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (context, position) {
          return taggedDetails(list[position], position);
        });
  }

  Widget taggedDetails(TaggedObject? document, pos) {
    return InkWell(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Row(
                children: <Widget>[
                  document!.taggeduserid!=null&&document!.taggeduserid!.profileimage!.length > 0
                      ? CircleAvatar(
                          radius: 24,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(document!.taggeduserid!.profileimage),
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
                          document!.taggeduserid!=null?document!.taggeduserid!.username:document.taggedtext,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 4,
                              fontFamily: "Poppins-Medium",
                              color: Colors.black),
                        ),
                      ),
                      /*document!.taggeduserid!=null? Container(
                        child: Text(
                          document!.taggeduserid!.email,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 3,
                              fontFamily: "Poppins-Medium",
                              color: Colors.grey),
                        ),
                      ):Container()*/
                    ],
                  )),
                ],
              ),
            ),
            Divider(),
            Container(
              height: 2,
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 5),
      ),
      onTap: () {},
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

  Widget getProfileView() {
    var uObj = userResponse;
    return Profile();
  }

  /* buildTextSpan(String s, List<dynamic>? mentions) {
    var regularStyle = TextStyle(color: Colors.black); //regular style
    var mentionStyle = TextStyle(color: Colors.blue); //style with mentions

    List<InlineSpan> children = [];

//return regular text if no users have been mentioned
    if (mentions == null || mentions.isEmpty) {
      children.add(TextSpan(text: s, style: regularStyle));
      return TextSpan(children: children);
    }

    s.splitMapJoin(
        RegExp(mentions.map((e) => '@' + e['userId']!).join('|')),
        onMatch: (Match match) {
          children.add(TextSpan(
              text: '@' + mentions.firstWhere((element)
          =>
          element['userId'] == match[0]!.substring(1)
          )['username']!,
          style: mentionStyle,
//app specific: navigate to user screen and pass the userId
          recognizer: TapGestureRecognizer()..onTap = ()
          => //navigation logic));
//return empty string that will not be used but has to be returned due to null-safety
          return
          '
          ';
//add regular textspan on no match
        }, onNonMatch: (String text) {
      children.add(TextSpan(
          text: text,
          style: regularStyle
      ));
      return '';
    }
    );

    return TextSpan(children: children);
  }
*/
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

class RegexTextHighlight extends StatelessWidget {
  final String text;
  final RegExp highlightRegex;

  const RegexTextHighlight({
    required this.text,
    required this.highlightRegex,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text.isEmpty) {
      return Text("", style: DefaultTextStyle.of(context).style);
    }
    RegExp hashHighlightRegex=RegExp(r"\B(#|@)[a-zA-Z0-9]+\b");
    List<TextSpan> spans = [];
    int start = 0;
    while (true) {
      final String? highlight =
      hashHighlightRegex.stringMatch(text.substring(start));

      if (highlight == null) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }

      final int indexOfHighlight = text.indexOf(highlight, start);

      if (indexOfHighlight == start) {
        // starts with highlight
        spans.add(_highlightSpan(highlight,context));
        start += highlight.length;
      } else {
        // normal + highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
        spans.add(_highlightSpan(highlight,context));
        start = indexOfHighlight + highlight.length;
      }
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  TextSpan _highlightSpan(String content,context) {
    return TextSpan(text: content, style: TextStyle(color: Colors.blue),recognizer: new TapGestureRecognizer()..onTap = (){
      log("haskTag");
      openHashList(context,content);
    });
  }
  void openHashList(context,String content){
    if(content.contains("#")){
      print("yesHash");
      Navigator.of(context)
          .pushNamed(HomeWidgetRoutes.screen17,arguments: {"HashTag":content});
    }
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content);
  }
}
