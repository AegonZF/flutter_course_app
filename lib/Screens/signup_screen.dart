import 'package:flutter/material.dart';
import 'package:flutter_course_app/Services/AuthServices/auth_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                'SignUp',
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
                obscureText: true,
                controller: passwordCTRL,
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
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      decorationColor: Colors.amber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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
                      Text('Google Sign Up'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: loader
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loader = true;
                          });
                          await AuthServices.handleSignUp(
                            emailCTRL.text.toString(),
                            passwordCTRL.text.toString(),
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
                        child: Text('Sign Up', style: TextStyle(fontSize: 12)),
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
