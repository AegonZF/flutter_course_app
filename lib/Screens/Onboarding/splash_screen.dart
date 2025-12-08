import 'package:flutter/material.dart';
import 'package:flutter_course_app/Screens/Home%20Screen/home_show_poll_screen.dart';
import 'package:flutter_course_app/Screens/signin_screen.dart';
import 'package:flutter_course_app/Services/AuthServices/auth_services.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));
    try {
      bool isLoggedIn = await AuthServices.userLogin();
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          child: isLoggedIn ? HomeShowPollScreen() : SigninScreen(),
          type: PageTransitionType.fade,
        ),
        (route) => false,
      );
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(child: SigninScreen(), type: PageTransitionType.fade),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/flutterSplash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
