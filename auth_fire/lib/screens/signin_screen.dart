import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_fire/reusable_widgets/reusable_widget.dart';
import 'package:auth_fire/screens/home_screen.dart';
import 'package:auth_fire/screens/bottom_bar.dart';
import 'package:auth_fire/screens/curved_bar.dart';

import 'package:auth_fire/screens/reset_password.dart';
import 'package:auth_fire/screens/signup_screen.dart';
import 'package:auth_fire/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:auth_fire/reusable_widgets/firebase_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("55d0ff"),
          hexStringToColor("00acdf"),
          hexStringToColor("0080bf")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo2.png"),

                const Text("Delivery",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40)),
                SizedBox(
                  height: 30,
                ),

                Material(
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        reusableTextField("Enter email", Icons.person_outline,
                            false, _emailTextController),
                        const SizedBox(
                          height: 20,
                        ),
                        reusableTextField("Enter Password", Icons.lock_outline,
                            true, _passwordTextController),
                        const SizedBox(
                          height: 5,
                        ),
                        forgetPassword(context),
                        firebaseUIButton(context, "Sign In", () {
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text,
                          )
                              .then((value) {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        curvedBarScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 900),
                              ),
                              // MaterialPageRoute(
                              //     builder: (context) => curvedBarScreen()),
                            );
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text('Welcome'),
                            //     backgroundColor:
                            //         Color.fromARGB(255, 19, 100, 192),
                            //     padding: EdgeInsets.all(20),
                            //     behavior: SnackBarBehavior.floating,
                            //     width: 300,
                            //     elevation: 30,
                            //     duration: Duration(milliseconds: 3000),
                            //   ),
                            // );
                          }).catchError((error, stackTrace) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please check your credentials'),
                                backgroundColor: Color.fromARGB(255, 150, 0, 0),
                                padding: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                width: 300,
                                elevation: 30,
                                duration: Duration(milliseconds: 3000),
                              ),
                            );
                          });
                        }),
                      ],
                    ),
                  ),
                ),

                // firebaseUIButton(context, "Sign In", () {
                //   FirebaseAuth.instance
                //       .signInWithEmailAndPassword(
                //           email: _emailTextController.text,
                //           password: _passwordTextController.text)
                //       .then((value) {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => curvedBarScreen()));
                //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //       content: Text('welcome'),
                //       backgroundColor: Color.fromARGB(255, 1, 104, 117),
                //       padding: EdgeInsets.all(20),
                //       behavior: SnackBarBehavior.floating,
                //       width: 300,
                //       elevation: 30,
                //       duration: Duration(milliseconds: 3000),
                //     ));
                //   }).catchError((error, stackTrace) {
                //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //       content: Text('Please check your credentials'),
                //       backgroundColor: Color.fromARGB(255, 150, 0, 0),
                //       padding: EdgeInsets.all(20),
                //       behavior: SnackBarBehavior.floating,
                //       width: 300,
                //       elevation: 30,
                //       duration: Duration(milliseconds: 3000),
                //     ));
                //     //print("Error ${error.toString()}");
                //   });
                // }),

                //google_sign_in()
                //signUpOption()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row google_sign_in() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseServices().signInWithGoogle();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return Colors.white;
            })),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/google.png",
                    height: 40,
                    width: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Login with Gmail",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ResetPassword(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 700),
          ),
          // MaterialPageRoute(builder: (context) => ResetPassword())
        ),
      ),
    );
  }
}
