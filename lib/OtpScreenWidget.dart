import 'dart:async';

import 'package:famewall/base/BaseState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import 'PrefUtils.dart';
import 'Utils.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';

class OtpWidget extends BasePage {
  OtpWidget({Key? key}) : super(key: key);

  @override
  OtpWidgetState createState() => OtpWidgetState();
}

class OtpWidgetState extends BasePageState<OtpWidget> {
  BaseApiService baseApiService = NetworkApiService();
  TextEditingController emailAddress = new TextEditingController();
  StreamSubscription? streamSubscription = null;
String emailId="";
  @override
  void initState() {
    super.initState();

    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        var loginResponse = event.data as LoginResponse;
        // emailAddress.text="";
        if (!loginResponse.iserror!) {
          PreferenceUtils.setBool("is_login", true);
          var name=loginResponse.username!;
          PreferenceUtils.setString("userName", name);
          PreferenceUtils.setString("token", loginResponse.userToken!);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          LoadingUtils.instance.showToast(loginResponse.message);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    emailId=arguments["emailId"];
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 1
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset("assets/images/app_logo.svg"),
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                      width: double.infinity,
                      child: Text(
                        "Activate Account",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.black,fontFamily: "Poppins-medium",
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                        child: TextField(
                            controller: emailAddress,
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
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 14,fontFamily: "Poppins-medium"),
                                hintText: "Enter otp",
                                fillColor: Color(0xFFFAFAFA)))),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          top: 10, bottom: 0, left: 30, right: 30),
                      child: Text(
                        "You will be received otp to your email, Please enter the otp to activate your account",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,fontFamily: "Poppins-medium",
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Utils.isEmpty(emailAddress.text.toString())) {
                            LoadingUtils.instance
                                .showToast("Please enter the otp");
                          } else {
                            var request = {
                              'email': emailId,
                              'emailotp': emailAddress.text.toString().trim(),
                            };
                            LoadingUtils.instance
                                .showLoadingIndicator("Please wait...");
                            print(request);
                            baseApiService.postResponse(
                                "activate", request, Status.LOGIN);
                          }
                        },
                        child: Text(
                          "Activate",
                          style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: "Poppins-medium"),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFFC4861A)),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                    ),
                  ],
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
