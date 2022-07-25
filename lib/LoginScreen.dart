import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/base/BaseState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'PrefUtils.dart';
import 'Utils.dart';
import 'api/ApiResponse.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';

class LoginWidget extends BasePage {
  LoginWidget({Key? key}) : super(key: key);

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends BasePageState<LoginWidget>
    with WidgetsBindingObserver {
  BaseApiService baseApiService = NetworkApiService();
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController passwordCntrl = new TextEditingController();
  StreamSubscription? streamSubscription = null;

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

  Future<User?> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      User? _user = (await _auth.signInWithCredential(authCredential)).user;

      //final User currentuser = await _auth.currentUser!;
      print("_user");
      print(_user!.email!);
      print(_user.getIdToken());
      gmailLogin(_user);
      return _user;
    } catch (e) {
      print("exception");
      print(e);
    }
  }

  void gmailLogin(User user) {
    isAuthLogin = true;
    var request = {
      'oauthid': user.uid ?? "",
      "email": user.email ?? "",
      "firstname": user.displayName ?? "",
      "lastname": "",
      "mobileno": user.phoneNumber ?? "",
      "profileimage": user.photoURL ?? "",
    };
    LoadingUtils.instance.showLoadingIndicator("Please wait...");
    baseApiService.postResponse("oauthlogin", request, Status.LOGIN);
  }

  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAuthLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        var loginResponse = event.data as LoginResponse;
        if (!loginResponse.iserror!) {
          PreferenceUtils.setBool("is_login", true);
          var name = loginResponse.username!;
          PreferenceUtils.setString("userName", name);
          PreferenceUtils.setString("userId", loginResponse.userid ?? "");
          PreferenceUtils.setString("token", loginResponse.userToken!);
          PreferenceUtils.setString(
              "userProfileImage", loginResponse.profileimage ?? "");
          FirebaseMessaging.instance.getToken().then((token) {
            return FirebaseFirestore.instance
                .collection("user")
                .doc(loginResponse.userid)
                .update({"token": token});
          }).then((value) => debugPrint("Done"));
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          LoadingUtils.instance.showToast(loginResponse.message);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription!.cancel();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 1
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Stack(
            children: [
              Align(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/images/app_logo.svg"),
                      /*Image(
                        image: AssetImage("assets/images/app_logo.png"),
                        height: 120,
                        width: 187,
                      ),*/
                      Container(
                          margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                          child: TextField(
                              controller: emailAddress,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.5),
                                        width: 0.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black.withOpacity(0.5),
                                        width: 0.5),
                                  ),
                                  filled: true,
                                  hintStyle: TextStyle(
                                      fontFamily: "Poppins-medium",
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 14),
                                  hintText: "Email address",
                                  fillColor: Color(0xFFFAFAFA)))),
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                        child: TextField(
                          controller: passwordCntrl,
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 0.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 0.5),
                              ),
                              filled: true,
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontFamily: "Poppins-medium",
                                  fontSize: 14),
                              hintText: "Password",
                              fillColor: Color(0xFFFAFAFA)),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(
                            top: 10, bottom: 0, left: 30, right: 25),
                        child: InkWell(
                          child: Padding(
                            child: Text(
                              "Forgot password?",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  fontSize: 14,
                                  color: Color(0xFFC4861A),
                                  fontWeight: FontWeight.bold),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                          onTap: () {
                            streamSubscription!.pause();
                            Navigator.pushNamed(context, '/forgot').then(
                                (value) => {streamSubscription!.resume()});
                          },
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Navigator.pushNamed(context, '/login');
                            if (Utils.isEmpty(emailAddress.text.toString())) {
                              LoadingUtils.instance
                                  .showToast("Please enter email address");
                            } else if (Utils.isEmpty(
                                passwordCntrl.text.toString())) {
                              LoadingUtils.instance
                                  .showToast("Please enter password");
                            } else {
                              var request = {
                                'email': emailAddress.text.toString().trim(),
                                "password": passwordCntrl.text.toString()
                              };
                              LoadingUtils.instance
                                  .showLoadingIndicator("Please wait...");
                              baseApiService.postResponse(
                                  "login", request, Status.LOGIN);
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Poppins-medium"),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xFFC4861A)),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: InkWell(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xFFC4861A)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                                margin: EdgeInsets.only(
                                    top: 10, bottom: 10, right: 5),
                                child: Text(
                                  "Google",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Poppins-medium",
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _signInWithGoogle();
                              },
                            )),
                            Expanded(
                                child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFC4861A)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2))),
                              margin:
                                  EdgeInsets.only(top: 10, bottom: 10, left: 5),
                              child: Text(
                                "Facebook",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Divider(),
                            )),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                    fontFamily: "Poppins-medium",
                                    fontSize: 12,
                                    color: Color(0xFFC4861A),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Divider(),
                            ))
                          ],
                        ),
                        margin: EdgeInsets.only(left: 30, right: 30),
                      ),
                      InkWell(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(
                                "Don’t have an account?",
                                style: TextStyle(
                                    fontFamily: "Poppins-medium",
                                    fontSize: 12,
                                    color: Color(0xFF000000).withOpacity(0.5)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(
                                " Sign up",
                                style: TextStyle(
                                    fontFamily: "Poppins-medium",
                                    fontSize: 12,
                                    color: Color(0xFFC4861A),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                      )
                    ],
                  ),
                ),
                alignment: Alignment.center,
              ),
              Align(
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        color: Color(0xFF000000).withOpacity(0.3),
                        height: 0.9,
                      ),
                    ],
                  ),
                ),
                alignment: Alignment.bottomCenter,
              )
            ],
          ),
        ),
      ),
    ));
  }
}
