//import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_fire/screens/signin_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image.network(FirebaseAuth.instance.currentUser!.photoURL!),
            //Text("${FirebaseAuth.instance.currentUser!.email}"),
            //Text("${FirebaseAuth.instance.currentUser!.displayName}"),
            ElevatedButton(
              child: Text("Logout"),
              onPressed: () {
                // FirebaseAuth.instance.signOut().then((value) {
                //   print("Signed Out");
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => SignInScreen()));
                // });
              },
            ),
          ],
        ),
      ),
    );
  }
}
