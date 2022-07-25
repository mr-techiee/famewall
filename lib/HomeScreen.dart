import 'package:famewall/notification/NotificationWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'HomeWidget.dart';
import 'global.dart';

class HomeScreenWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenWidgetState();
  }
}

class HomeScreenWidgetState extends State<HomeScreenWidget> {
  int viewPos = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
          body: viewPos == 0 ? HomeWidget() : viewPos == 4? NotificationWidget():Container(child: Center(child: Text("Coming soon"),),),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: selectedTabColor,
                border: Border(
                    top: BorderSide(color: selectedTabColor, width: 1.0))),
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
                viewPos = i;
                setState(() {});
                // this._selectTab(i);
              },
              // this will be set when a new tab is tapped
              items: [
                BottomNavigationBarItem(
                  icon: Image(
                    image: AssetImage("assets/images/home_icon.png"),
                    color: viewPos == 0 ? selectedTabColor : appColorBlack,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                      image: AssetImage("assets/images/message_icon.png"),
                      color: viewPos == 1 ? selectedTabColor : appColorBlack),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    child: Image(
                        image: AssetImage("assets/images/trend.png"),
                        color: viewPos == 2 ? selectedTabColor : appColorBlack),
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
                      color: viewPos == 3 ? selectedTabColor : appColorBlack),
                  // new Icon(
                  //   CupertinoIcons.bell,
                  //   size: 25,
                  // ),
                  label: 'Video',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                      image: AssetImage("assets/images/bell.png"),
                      color: viewPos == 4 ? selectedTabColor : appColorBlack),
                  // new Icon(
                  //   CupertinoIcons.bell,
                  //   size: 25,
                  // ),
                  label: 'Notification',
                ),
              ],
            ),
          ),
        )),
        onWillPop: _backPressed);
  }

  Future<bool> _backPressed() async {
    //Checks if current Navigator still has screens on the stack.
    if (viewPos != 0) {
      print("viewPos");
      viewPos = 0;
      setState(() {});
      return Future<bool>.value(false);
    }
    return Future<bool>.value(true);
  }
}
