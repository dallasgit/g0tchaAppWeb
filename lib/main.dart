import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ig0tchaapp/pages/common.dart';
import 'package:ig0tchaapp/pages/firebase.dart';
import 'package:ig0tchaapp/pages/login.dart';
import 'package:ig0tchaapp/pages/operatorreward.dart';
//import 'pages/customer/claimreward.dart';
import 'pages/deliveryfee.dart';
import 'pages/user_session.dart'; // import the deliveryfee page file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  runApp(const LoginScreen()); //RiderAndOperatorLoginScreem
  //runApp(const CustomerRewardApp()); //CustomerRewardScreen
}

class WelcomeScreen extends StatelessWidget {
  final CurrentUserSessionData currentUserSessionData;
  const WelcomeScreen({super.key, required this.currentUserSessionData});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'g0tchaApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(
          title: 'Hello Gotcha Fam ${currentUserSessionData.loginName}!',
          currentUserSessionData: currentUserSessionData),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final CurrentUserSessionData currentUserSessionData;
  const MyHomePage(
      {super.key, required this.title, required this.currentUserSessionData});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Start the session timer

    final Timer sessionTimer =
        Timer(const Duration(milliseconds: (10 * 60 * 1000)), () {
      //10 * 60 * 1000; // 10 minutes in milliseconds
      UserSession userSession = UserSession();
      // Clear the session data and redirect the user to the login page
      userSession.clearSessionData();
      redirectToLoginPage();
    });
  }

  void redirectToLoginPage() {
    // Code to redirect the user to the login page...
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRiderRole = (widget.currentUserSessionData.roleName == "rider");
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return isRiderRole ? const DeliveryFeeApp() : const OperatorReward();
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
