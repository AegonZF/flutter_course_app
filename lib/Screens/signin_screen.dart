import 'package:flutter/material.dart';
import 'package:flutter_course_app/Screens/forget_password_screen.dart';
import 'package:flutter_course_app/Screens/signup_screen.dart';
import 'package:flutter_course_app/Services/AuthServices/auth_services.dart';
import 'package:page_transition/page_transition.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailCTRL = TextEditingController();
  TextEditingController passwordCTRL = TextEditingController();
  bool loader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/login_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'SignIn',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: emailCTRL,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordCTRL,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: ForgetPasswordScreen(),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        decorationColor: Colors.amber,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    AuthServices.signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Constrain the icon so it won't overflow the button's height.
                      Image.asset(
                        'assets/images/google_icon.png',
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 10),
                      Text('Google Sign In'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: loader
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loader = true;
                          });
                          await AuthServices.handleSignIn(
                            emailCTRL.text,
                            passwordCTRL.text,
                            context,
                          );
                          setState(() {
                            loader = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Sign In', style: TextStyle(fontSize: 12)),
                      ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an Account?",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      ' SignUp',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
