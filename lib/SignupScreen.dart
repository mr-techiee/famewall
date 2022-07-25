import 'dart:async';
import 'dart:convert';

import 'package:famewall/base/BaseState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;

import 'PrefUtils.dart';
import 'Utils.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';

class SignupWidget extends BasePage {
  SignupWidget({Key? key}) : super(key: key);

  @override
  SignupWidgetState createState() => SignupWidgetState();
}

class SignupWidgetState extends BasePageState<SignupWidget> {
  TextEditingController emailAddress = new TextEditingController();
  TextEditingController passwordCntrl = new TextEditingController();
  TextEditingController firstNameCntrl = new TextEditingController();
  TextEditingController lastNameCtrl = new TextEditingController();
  TextEditingController mobileNumberCtrl = new TextEditingController();
  StreamSubscription? streamSubscription = null;
  BaseApiService baseApiService = NetworkApiService();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAuthLogin = false;



    @override
    void initState() {
      // TODO: implement initState
      super.initState();

      LoadingUtils.instance.setContext(context);
      streamSubscription = eventBus.on<ApiResponse>().listen((event) {
        LoadingUtils.instance.hideOpenDialog();
        if (event.status == Status.COMPLETED) {
          var loginResponse = event.data as LoginResponse;
          if (isAuthLogin) {
            PreferenceUtils.setBool("is_login", true);
            var name = loginResponse.username!;
            PreferenceUtils.setString("userName", name);
            PreferenceUtils.setString("token", loginResponse.userToken!);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            if (!loginResponse.iserror!) {
              Navigator.pushReplacementNamed(context, '/otp',
                  arguments: {'emailId': emailAddress.text.toString()});
            } else {
              LoadingUtils.instance.showToast(loginResponse.message);
            }
          }
        }
      });
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
        isAuthLogin = true;
        var request = {
          'oauthid': _user.uid ?? "",
          "email": _user.email ?? "",
          "firstname": _user.displayName ?? "",
          "lastname": "",
          "mobileno": _user.phoneNumber ?? "",
          "profileimage": _user.photoURL ?? "",
        };
        LoadingUtils.instance
            .showLoadingIndicator("Please wait...");
        baseApiService.postResponse(
            "oauthlogin", request, Status.LOGIN);
        return _user;
      } catch (e) {
        print("exception");
        print(e);
      }
    }

    void gmailLogin(User user) {

    }

    @override
    void dispose() {
      // TODO: implement dispose
      super.dispose();
      streamSubscription!.cancel();
    }

    @override
    Widget build(BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 1

      return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white, resizeToAvoidBottomInset: false,
            body: Container(
              child: Stack(
                children: [
                  Align(
                    child: InkWell(
                      child: Container(
                        child: Image(
                          image: AssetImage("assets/images/back_icon.png"),
                        ),
                        margin: EdgeInsets.only(left: 20, top: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  Align(
                    child: Padding(child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SvgPicture.asset("assets/images/app_logo.svg"),
                          /*  Image(
                      image: AssetImage("assets/images/app_logo.png"),
                      height: 120,
                      width: 187,
                    ),*/
                          Container(
                            margin: EdgeInsets.only(
                                top: 30, left: 30, right: 30),
                            width: double.infinity,
                            child: Text(
                              "Sign up",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontFamily: "Poppins-medium",
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: 30, right: 30, top: 10),
                              child: TextField(
                                  controller: emailAddress,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black.withOpacity(
                                                0.5),
                                            width: 0.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black.withOpacity(
                                                0.5),
                                            width: 0.5),
                                      ),
                                      filled: true,
                                      hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 14,fontFamily: "Poppins-medium"),
                                      hintText: "Email address",
                                      fillColor: Color(0xFFFAFAFA)))),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: TextField(
                                        controller: firstNameCntrl,
                                        decoration: InputDecoration(
                                            contentPadding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  width: 0.5),
                                            ),
                                            filled: true,
                                            hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                    0.5),
                                                fontSize: 14,fontFamily: "Poppins-medium"),
                                            hintText: "First Name",
                                            fillColor: Color(0xFFFAFAFA)),
                                      ),
                                    )),
                                Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: TextField(
                                        controller: lastNameCtrl,
                                        decoration: InputDecoration(
                                            contentPadding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  width: 0.5),
                                            ),
                                            filled: true,
                                            hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                    0.5),
                                                fontSize: 14,fontFamily: "Poppins-medium"),
                                            hintText: "Last Name",
                                            fillColor: Color(0xFFFAFAFA)),
                                      ),
                                    )),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10),
                            child: TextField(
                              controller: mobileNumberCtrl,
                              keyboardType: TextInputType.number,
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
                                      fontSize: 14,fontFamily: "Poppins-medium"),
                                  hintText: "Phone (+91 1234567890)",
                                  fillColor: Color(0xFFFAFAFA)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10),
                            child: TextField(
                              obscureText: true,
                              controller: passwordCntrl,
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
                                      fontSize: 14,fontFamily: "Poppins-medium"),
                                  hintText: "Password",
                                  fillColor: Color(0xFFFAFAFA)),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                                top: 10, bottom: 0, left: 30, right: 30),
                            child: Text(
                              "By signing up you agree to our Terms of Use and Privacy Policy",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontFamily: "Poppins-medium",
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.pushNamed(context, '/login');
                                if (Utils.isEmpty(
                                    emailAddress.text.toString())) {
                                  LoadingUtils.instance
                                      .showToast("Please enter email address");
                                } else if (Utils.isEmpty(
                                    firstNameCntrl.text.toString())) {
                                  LoadingUtils.instance
                                      .showToast("Please enter first name");
                                } else if (Utils.isEmpty(
                                    lastNameCtrl.text.toString())) {
                                  LoadingUtils.instance
                                      .showToast("Please enter last name");
                                } else if (Utils.isEmpty(
                                    mobileNumberCtrl.text.toString())) {
                                  LoadingUtils.instance
                                      .showToast(
                                      "Please enter your mobile number");
                                } else if (Utils.isEmpty(
                                    passwordCntrl.text.toString())) {
                                  LoadingUtils.instance
                                      .showToast("Please enter password");
                                } else {
                                  var request = {
                                    'email': emailAddress.text.toString()
                                        .trim(),
                                    "password": passwordCntrl.text.toString(),
                                    "firstname": firstNameCntrl.text.toString(),
                                    "lastname": lastNameCtrl.text.toString(),
                                    "mobileno": mobileNumberCtrl.text
                                        .toString(),
                                  };
                                  LoadingUtils.instance
                                      .showLoadingIndicator("Please wait...");
                                  isAuthLogin = false;
                                  baseApiService.postResponse(
                                      "signup", request, Status.SIGNUP);
                                }
                                //Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFC4861A)),
                            ),
                            width: double.infinity,
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 20),
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                                top: 10, bottom: 0, left: 30, right: 30),
                            child: Text(
                              "Or sign up social account",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,fontFamily: "Poppins-medium",
                                color: Colors.black,
                              ),
                            ),
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
                                            Border.all(
                                                color: Color(0xFFC4861A)),
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(2))),
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10, right: 5),
                                        child: Text(
                                          "Google",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontFamily: "Poppins-medium",
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
                                    child: InkWell(child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xFFC4861A)),
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(2))),
                                      margin:
                                      EdgeInsets.only(
                                          top: 10, bottom: 10, left: 5),
                                      child: Text(
                                        "Facebook",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: "Poppins-medium",
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ), onTap: () {
                                      signInWithFacebook();
                                    },)),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: 30, right: 30, top: 10),
                          ),
                        ],
                      ),
                    ), padding: EdgeInsets.only(
                        bottom: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom+50)),
                    alignment: Alignment.center,
                  ),
                  Align(
                    child: Container(
                      padding: EdgeInsets.only(top: 15, bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                            color: Color(0xFF000000).withOpacity(0.3),
                            height: 0.9,
                          ),
                          InkWell(
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                          fontSize: 12,fontFamily: "Poppins-medium",
                                          color:
                                          Color(0xFF000000).withOpacity(0.5)),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                          fontSize: 12,fontFamily: "Poppins-medium",
                                          color: Color(0xFFC4861A),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                          )
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                  )
                ],
              ),
            ),
          ));
    }
  Future<Resource?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(permissions: ["email","public_profile"]);
      switch (result.status) {
        case LoginStatus.success:
          print(result.accessToken!.token);
          final graphResponse = await http.get(
              Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken!.token}'));
          final profile = jsonDecode(graphResponse.body);
          print(profile);
          final AuthCredential facebookCredential =

          FacebookAuthProvider.credential(result.accessToken!.token);

          final userCredential =
          await _auth.signInWithCredential(facebookCredential);
          return Resource(status: Status.Success);
        case LoginStatus.cancelled:
          return Resource(status: Status.Cancelled);
        case LoginStatus.failed:
          return Resource(status: Status.Error);
        default:
          return null;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print("e.email");
      throw e;
    }
  }
  static loginWithFacebook() async {
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    if (!isLogged) {
      LoginResult result = await facebookAuth
          .login(); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(
            await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;


     /* return await handleFacebookLogin(
          await facebookAuth.getUserData(), token!);*/
    }
  }
  static handleFacebookLogin(
      Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance
        .signInWithCredential(
        auth.FacebookAuthProvider.credential(token.token));
   // User? user = await getCurrentUser(authResult.user?.uid ?? '');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }

  }

}
class Resource{

  final Status status;
  Resource({required this.status});
}

