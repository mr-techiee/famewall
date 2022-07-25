import 'package:famewall/SignupScreen.dart';
import 'package:famewall/SplashScreen.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ForgotPasswordScreen.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'OtpScreenWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // status bar color
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Famewal',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashWidget(),
        '/login': (context) => LoginWidget(),
        '/signup': (context) => SignupWidget(),
        '/forgot': (context) => ForgotPasswordWidget(),
        '/home': (context) => MainContainerWidget(),
        '/otp': (context) => OtpWidget(),
      },
    );
  }
}
