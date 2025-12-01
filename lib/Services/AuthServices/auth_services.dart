// import 'dart:developer';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static Future<String> signUpWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Sign-Up succesful!';
    } catch (e) {
      return 'Error during sign-up! : ${e.toString()}';
    }
  }

  static handleSignUp(
    String email,
    String password,
    BuildContext context,
  ) async {
    String message = await signUpWithEmail(email, password);
    showSnackBar(message, context);
  }

  static Future<String> signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Sign-In succesful!';
    } catch (e) {
      return 'Error during sign-In! : ${e.toString()}';
    }
  }

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      log(userCredential.toString());
      return null;
    } catch (e) {
      log('Google Sign-In Error: $e');
      return null;
    }
  }

  static handleSignIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    String message = await signInWithEmail(email, password);
    showSnackBar(message, context);
  }

  static void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<void> resetForgetPasswordsendEmail(
    String email,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSnackBar('Reset password Email ', context);
    } catch (e) {
      showSnackBar('Error in reset Password ${e.toString()}', context);
    }
  }
}
