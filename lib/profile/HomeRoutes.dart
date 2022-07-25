import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/FollowerListWidget.dart';
import 'package:famewall/FollowerVideoWidget.dart';
import 'package:famewall/LoginScreen.dart';
import 'package:famewall/PrefUtils.dart';
import 'package:famewall/TagWidget.dart';
import 'package:famewall/Utils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/chat/chat_history_screen/chat_history_screen.dart';
import 'package:famewall/chat/chat_screen/chat_screen.dart';
import 'package:famewall/chat/chat_screen/provider/chat_screen_provider.dart';
import 'package:famewall/notification/NotificationWidget.dart';
import 'package:famewall/post/HashPostDetails.dart';
import 'package:famewall/post/PostDetails.dart';
import 'package:famewall/profile/profile.dart';
import 'package:famewall/search/search_new.dart';
import 'package:famewall/story/AddStoryWidget.dart';
import 'package:famewall/story/SingleStoryWidget.dart';
import 'package:famewall/trend/TrendDetails.dart';
import 'package:famewall/trend/TrendWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../HomeWidget.dart';
import '../StoryWidget.dart';
import '../global.dart';

class HomeWidgetRoutes {
  static const screen1 = "HomeScreen";
  static const screen2 = "Profile";
  static const screen3 = "FollowList";
  static const screen4 = "Search";
  static const screen5 = "home";
  static const screen6 = "notification";
  static const screen7 = "addStory";
  static const screen8 = "myStories";
  static const screen9 = "postDetails";
  static const screen10 = "moreStories";
  static const screen11 = "trend";
  static const screen12 = "tag";
  static const screen13 = "message";
  static const screen14 = "chat";
  static const screen15 = "FollowerVideo";
  static const screen16 = "TrendDetails";
  static const screen17 = "HashPostDetails";
  static const screen18 = "login";
  static const screen19 = "/home";
}

class _HomeWidgetStateProvider extends InheritedWidget {
  final HomeWidgetState? state;

  _HomeWidgetStateProvider({this.state, child}) : super(child: child);

  @override
  bool updateShouldNotify(_HomeWidgetStateProvider old) => false;
}

class MainContainerWidget extends StatefulWidget {
  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<MainContainerWidget> {
  static HomeWidgetState? of(BuildContext context) {
    return (context
                .dependOnInheritedWidgetOfExactType<_HomeWidgetStateProvider>()
            as _HomeWidgetStateProvider)
        .state;
  }

  int viewPos = 0;
  bool? isShowBottom = true;

  final navKey = GlobalKey<NavigatorState>();
  final userId = PreferenceUtils.getString("userId", "");

  final String initialRouteName = "screen1";
  String currentRouteName = "screen1";

  get isInitialRoute => currentRouteName == initialRouteName;

  get routeTitle => routeTitles[currentRouteName];

  void updateBottomNav() {
    isShowBottom = true;
    setState(() {});
  }

  Future<bool> onBackPress() async {
    if (!navKey.currentState!.canPop()) {
      return true;
    }
    navKey.currentState!.pop();
    updateRouteName();
    return false;
  }

  void updateRouteName() {
    /// Check current route with popUntil callback function
    navKey.currentState!.popUntil((route) {
      final String? routeName = route.settings.name;
      log("routeName1");
      log(routeName.toString());

      if (viewPos == 4 || viewPos == 2) {
        if (routeName == HomeWidgetRoutes.screen11 && viewPos == 2) {
        } else if (routeName == HomeWidgetRoutes.screen6 && viewPos == 4) {
        } else {
          viewPos = 0;
          setState(() {});
          for (int i = 0; i < 10; i++) {
            if (!navKey.currentState!.canPop()) {
              break;
            }
            navKey.currentState!.pop();
            updateRouteName();
          }
        }
      }
      if (routeName == HomeWidgetRoutes.screen7) {
        isShowBottom = false;
      } else {
        print("isShowBottom");
        isShowBottom = true;
      }
      setState(() {
        currentRouteName = routeName!;
      });

      /// Return true to not pop
      return true;
    });
  }

  @override
  void didUpdateWidget(covariant MainContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(oldWidget);
    print("oldWidget111");
  }

  @override
  Widget build(BuildContext context) {
    return _HomeWidgetStateProvider(
      state: this,
      child: WillPopScope(
        onWillPop: onBackPress,
        child: Scaffold(
          body: MaterialApp(
            navigatorKey: navKey,
            debugShowCheckedModeBanner: false,

            /// Add widget (activity) specific styles
            /// Could also be set to global style with [Theme.of(context)]
            theme: ThemeData(
              backgroundColor: Color(0xFFF3F3F3),

              /// Change animation to iOS like slide right animation
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              }),
            ),
            home: HomeWidget(),
            onGenerateRoute: onGenerateRoute,
          ),
          bottomNavigationBar: isShowBottom!
              ? Container(
                  decoration: BoxDecoration(
                      color: selectedTabColor,
                      border: Border(
                          top:
                              BorderSide(color: selectedTabColor, width: 1.0))),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: selectedTabColor,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    unselectedIconTheme: IconThemeData(color: selectedTabColor),
                    iconSize: 22,
                    selectedLabelStyle: TextStyle(
                      color: selectedTabColor,
                      fontFamily: "Poppins-medium",
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-medium",
                    ),
                    selectedIconTheme: IconThemeData(size: 28),
                    unselectedItemColor: appColorGrey,
                    currentIndex: viewPos,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    onTap: (int i) {
                      print("i.toString()");
                      print(i.toString());
                      if (i == 4) {
                        viewPos = i;
                        setState(() {});
                        navKey.currentState!
                            .pushNamed(HomeWidgetRoutes.screen6);
                        // Navigator.of(context).pushNamed(HomeWidgetRoutes.screen6);
                      } else if (i == 2) {
                        viewPos = i;
                        setState(() {});
                        navKey.currentState!
                            .pushNamed(HomeWidgetRoutes.screen11);
                      } else if (i == 0) {
                        viewPos = i;
                        setState(() {});
                        for (int i = 0; i < 10; i++) {
                          if (!navKey.currentState!.canPop()) {
                            break;
                          }
                          navKey.currentState!.pop();
                          updateRouteName();
                        }
                        eventBus.fire(ApiResponse(Status.REFRESH, null, null));
                      } else if (i == 1) {
                        viewPos = i;
                        setState(() {});
                        navKey.currentState!
                            .pushNamed(HomeWidgetRoutes.screen13);
                      } else if (i == 3) {
                        viewPos = i;
                        setState(() {});
                        navKey.currentState!
                            .pushNamed(HomeWidgetRoutes.screen15);
                      }

                      // this._selectTab(i);
                    },
                    // this will be set when a new tab is tapped
                    items: [
                      BottomNavigationBarItem(
                        icon: Image(
                          image: AssetImage("assets/images/home_icon.png"),
                          color:
                              viewPos == 0 ? selectedTabColor : appColorBlack,
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Image(
                              image:
                                  AssetImage("assets/images/message_icon.png"),
                              color: viewPos == 1
                                  ? selectedTabColor
                                  : appColorBlack,
                            ),
                            !Utils.isEmpty(userId)
                                ? StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("chatList")
                                        .doc(userId)
                                        .collection(userId)
                                        .orderBy("timestamp", descending: true)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        List chatList =
                                            (snapshot.data as QuerySnapshot)
                                                .docs;
                                        int count = 0;
                                        for (var document in chatList) {
                                          if (document.data()['badge'] > 0) {
                                            count++;
                                          }
                                        }
                                        if (count == 0) {
                                          return const SizedBox();
                                        }
                                        final String countText =
                                            count > 9 ? "9+" : count.toString();
                                        return Positioned(
                                          top: -8,
                                          right: -8,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Center(
                                              child: Text(
                                                countText,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  )
                                : Container()
                          ],
                        ),
                        label: 'Message',
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          child: Image(
                              image: AssetImage("assets/images/trend.png"),
                              color: viewPos == 2
                                  ? selectedTabColor
                                  : appColorBlack),
                          margin: EdgeInsets.only(top: 5),
                        ),
                        // new Icon(
                        //   CupertinoIcons.bell,
                        //   size: 25,
                        // ),
                        label: 'Trend',
                      ),
                      BottomNavigationBarItem(
                        icon: Image(
                            image: AssetImage("assets/images/video_icon.png"),
                            color: viewPos == 3
                                ? selectedTabColor
                                : appColorBlack),
                        // new Icon(
                        //   CupertinoIcons.bell,
                        //   size: 25,
                        // ),
                        label: 'Video',
                      ),
                      BottomNavigationBarItem(
                        icon: Image(
                            image: AssetImage("assets/images/bell.png"),
                            color: viewPos == 4
                                ? selectedTabColor
                                : appColorBlack),
                        // new Icon(
                        //   CupertinoIcons.bell,
                        //   size: 25,
                        // ),
                        label: 'Notification',
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// Screen map (fragments)
  final routes = <String, Widget>{
    HomeWidgetRoutes.screen1: HomeWidget(),
    HomeWidgetRoutes.screen2: Profile(),
    HomeWidgetRoutes.screen3: FolloweListWidget(),
    HomeWidgetRoutes.screen4: SearchFeed(),
    HomeWidgetRoutes.screen5: MainContainerWidget(),
    HomeWidgetRoutes.screen6: NotificationWidget(),
    HomeWidgetRoutes.screen7: AddStoryWidgetScreen(),
    HomeWidgetRoutes.screen8: MoreStories(),
    HomeWidgetRoutes.screen9: PostDetails(),
    HomeWidgetRoutes.screen10: MoreStories1(),
    HomeWidgetRoutes.screen11: TrendWidget(),
    HomeWidgetRoutes.screen12: TagWidget(),
    HomeWidgetRoutes.screen13: ChatHistoryScreen(),
    HomeWidgetRoutes.screen15: FollowerVideoWidget(),
    HomeWidgetRoutes.screen14: ChangeNotifierProvider<ChatScreenProvider>(
      create: (context) => ChatScreenProvider(),
      child: ChatScreen(),
    ),
    HomeWidgetRoutes.screen16: TrendDetails(),
    HomeWidgetRoutes.screen17: HashPostDetails(),
    HomeWidgetRoutes.screen18: LoginWidget(),
    HomeWidgetRoutes.screen19: HomeWidget(),
  };

  void addWidget(Widget widget) {
    routes.putIfAbsent(HomeWidgetRoutes.screen1, () => widget);
  }

  /// Screen titles (fragment titles)
  final routeTitles = <String, String>{
    HomeWidgetRoutes.screen1: "Home Screen 1",
    HomeWidgetRoutes.screen2: "Home Screen 2",
    HomeWidgetRoutes.screen3: "Home Screen 3"
  };

  /// Navigation function (similar to navigateTo(Fragment fragment))
  Route onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    print(routeName);
    if (routeName == HomeWidgetRoutes.screen7 ||
        routeName == HomeWidgetRoutes.screen8 ||
        routeName == HomeWidgetRoutes.screen14||routeName == HomeWidgetRoutes.screen18) {
      isShowBottom = false;
    } else {
      isShowBottom = true;
    }
    print("routeName");
    print(routeName);
    final Widget nextWidget = routes[routeName]!;
    setState(() {
      currentRouteName = routeName!;
    });

    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => nextWidget,
    );
  }
}
