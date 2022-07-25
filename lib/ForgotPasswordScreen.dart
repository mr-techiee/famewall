import 'dart:async';

import 'package:famewall/base/BaseState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'Utils.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';

class ForgotPasswordWidget extends BasePage {
  ForgotPasswordWidget({Key? key}) : super(key: key);

  @override
  ForgotPasswordWidgetState createState() => ForgotPasswordWidgetState();
}

class ForgotPasswordWidgetState extends BasePageState<ForgotPasswordWidget> {
  BaseApiService baseApiService = NetworkApiService();
  TextEditingController emailAddress = new TextEditingController();
  StreamSubscription? streamSubscription = null;
  @override
  void initState() {
    super.initState();
    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      LoadingUtils.instance.hideOpenDialog();
      if (event.status == Status.COMPLETED) {
        var loginResponse = event.data as CommonResponse;
       // emailAddress.text="";
      /*  if (!loginResponse.iserror!) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {*/
          LoadingUtils.instance.showToast(loginResponse.message);
      //  }
      }
    });
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
                child: InkWell(child: Container(
                  child: Image(
                    image: AssetImage("assets/images/back_icon.png"),
                  ),
                  margin: EdgeInsets.only(left: 20, top: 20),
                ),onTap: (){
                  Navigator.of(context).pop();
                },),
                alignment: Alignment.topLeft,
              ),
              Align(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage("assets/images/app_logo.png"),
                      height: 120,
                      width: 187,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                      width: double.infinity,
                      child: Text(
                        "Forgot Password?",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: "Poppins-medium",
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    Container(
                        margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                        child: TextField(controller: emailAddress,
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
                                hintText: "Email address",
                                fillColor: Color(0xFFFAFAFA)))),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          top: 10, bottom: 0, left: 30, right: 30),
                      child: Text(
                        "By signing up you agree to our Terms of Use and Privacy Policy",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.5),fontFamily: "Poppins-medium"
                        ),
                      ),
                    ),

                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Utils.isEmpty(emailAddress.text.toString())) {
                            LoadingUtils.instance
                                .showToast("Please enter email address");
                          }else {
                            var request = {
                              'email': emailAddress.text.toString().trim(),
                            };
                            LoadingUtils.instance
                                .showLoadingIndicator("Please wait...");
                            baseApiService.postResponse(
                                "forgotpassword", request, Status.FORGOT_PASSWORD);
                          }
                        },
                        child: Text(
                          "Send Me Now",
                          style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: "Poppins-medium"),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xFFC4861A)),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 30, right: 30,top: 30),
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
                        color: Color(0xFF000000).withOpacity(0.3),height: 0.9,
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
