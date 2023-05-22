import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_fire/reusable_widgets/reusable_widget.dart';
import 'package:auth_fire/screens/home_screen.dart';
import 'package:auth_fire/utils/color_utils.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
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
                        reusableTextField("Enter Email Id",
                            Icons.person_outline, false, _emailTextController),
                        const SizedBox(
                          height: 20,
                        ),
                        firebaseUIButton(context, "Reset Password", () {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(
                                  email: _emailTextController.text)
                              .then((value) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('please check your email'),
                              backgroundColor:
                                  Color.fromARGB(255, 19, 100, 192),
                              padding: EdgeInsets.all(20),
                              behavior: SnackBarBehavior.floating,
                              width: 300,
                              elevation: 30,
                              duration: Duration(milliseconds: 3000),
                            ));
                          }).catchError((error, stackTrace) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Please enter your email'),
                              backgroundColor: Color.fromARGB(255, 150, 0, 0),
                              padding: EdgeInsets.all(20),
                              behavior: SnackBarBehavior.floating,
                              width: 300,
                              elevation: 30,
                              duration: Duration(milliseconds: 3000),
                            ));
                            //print("Error ${error.toString()}");
                          });
                        })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
