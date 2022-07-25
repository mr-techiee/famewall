import 'package:famewall/base/BaseState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_keyhash/flutter_facebook_keyhash.dart';
import 'package:flutter_svg/svg.dart';

import 'PrefUtils.dart';

class SplashWidget extends BasePage {
  SplashWidget({Key? key}) : super(key: key);
  @override
  SplashWidgetState createState() => SplashWidgetState();

}

class SplashWidgetState extends BasePageState<SplashWidget> {
  bool isLoggedIn=false;
  String username="";
  void printKeyHash() async{

    String? key=await FlutterFacebookKeyhash.getFaceBookKeyHash ??
        'Unknown platform version';
    print(key??"");

  }
  @override
  void initState() {
    super.initState();
    PreferenceUtils.init();
    printKeyHash();
    Future.delayed(Duration(seconds: 2),(){
      username = PreferenceUtils.getString("userName","");
      isLoggedIn=PreferenceUtils.getBool("is_login")!;
      if(isLoggedIn==null||!isLoggedIn){
        Navigator.pushReplacementNamed(context, '/login');
      }else{
        /*setState(() {

        });*/
        Navigator.pushReplacementNamed(context, '/home');
      }

    });

  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 1

    return SafeArea(
        child: Scaffold(backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Stack(children: [
           Align(child:  Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               SvgPicture.asset("assets/images/app_logo.svg"),
               /*Image(
                 image: AssetImage("assets/images/app_logo.png"),
                 height: 120,
                 width: 187,
               ),*/
               isLoggedIn?Container(
                 child: CircleAvatar(
                   backgroundColor: Colors.brown.shade800,
                   radius: 40,
                   child:  Text(username.substring(0,2).toUpperCase()),
                 ),
                 margin: EdgeInsets.only(top: 30),
               ):Container(),
               isLoggedIn?Container(
                 margin: EdgeInsets.only(top: 10, bottom: 10),
                 child: Text(
                   username,
                   style: TextStyle(
                       fontSize: 14,fontFamily: "Poppins-medium",
                       color: Colors.black,
                       fontWeight: FontWeight.bold),
                 ),
               ):Container(),
               isLoggedIn?Container(
                 child: Material(child: ElevatedButton(
                   onPressed: () {
                     if(!isLoggedIn){
                       Navigator.pushReplacementNamed(context, '/login');
                     }else{
                       Navigator.pushReplacementNamed(context, '/home');
                     }
                   },
                   child: Text(
                     "Login",
                     style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: "Poppins-medium"),
                   ),
                   style: ElevatedButton.styleFrom(primary: Color(0xFFC4861A)),
                 ),),
                 width: double.infinity,
                 margin: EdgeInsets.only(left: 40, right: 40),
               ):Container(),
               isLoggedIn?InkWell(child: Container(
                 margin: EdgeInsets.only(top: 30, bottom: 20),
                 child: Text(
                   "Switch accounts",
                   style: TextStyle(fontFamily: "Poppins-medium",
                       fontSize: 14,
                       color: Color(0xFFC4861A),
                       fontWeight: FontWeight.bold),
                 ),
               ),onTap: (){
                 Navigator.pushReplacementNamed(context, '/login');
               },):Container(),
             ],
           ),alignment: Alignment.center,),
/*
            Align(child: Container(padding: EdgeInsets.only(top: 10,bottom: 20),child: Column(mainAxisSize: MainAxisSize.min,children: [
              Divider(color: Color(0xFF000000).withOpacity(0.5),),
              InkWell(child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,children: [
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    "Don’t have an account?",
                    style: TextStyle(fontFamily: "Poppins-medium",
                        fontSize: 12,
                        color: Color(0xFF000000).withOpacity(0.3)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    " Sign up",
                    style: TextStyle(fontFamily: "Poppins-medium",
                        fontSize: 12,
                        color: Color(0xFFC4861A),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],),onTap: (){
                Navigator.pushReplacementNamed(context, '/signup');
              },)
            ],),),alignment: Alignment.bottomCenter,)
*/
          ],),
        ),
      ),
    ));
  }
}
