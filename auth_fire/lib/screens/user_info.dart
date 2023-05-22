import 'dart:io';
import 'package:auth_fire/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class profile extends StatefulWidget {
  final User? user;

  profile({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<profile> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  String? _firstName;
  String? _lastName;
  String? _phone;
  String? _imageprofile;
  bool _isEditing = false;
  String imageUrl = ' ';
  File? _profileImage;
  String? _profileImageUrl;
  Icon? myicon;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users_list')
          .doc(user.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _profileImageUrl = snapshot.data()?['profileImageUrl'];
          });
        }
      });
    }
    _loadUserData();
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });

      try {
        final fileName = path.basename(_profileImage!.path);
        final destination =
            'profile_images/$fileName'; // Replace with your desired storage path

        await FirebaseStorage.instance.ref(destination).putFile(_profileImage!);

        // Get the download URL of the uploaded image
        final downloadURL =
            await FirebaseStorage.instance.ref(destination).getDownloadURL();
        setState(() {
          _profileImageUrl = downloadURL;
        });
        // Save the downloadURL to Firestore or use it as needed
        // Implement your logic here to save the downloadURL to Firestore or use it in your app
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance
              .collection('users_list')
              .doc(user.uid)
              .update({'profileImageUrl': downloadURL});
        }
      } on FirebaseException catch (e) {
        // Handle any errors that occur during the upload process
        print(e);
      }
    }
  }

  Future<void> deletePhotoFromFirebase(String photoUrl, String userId) async {
    try {
      // Create a reference to the photo in Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(photoUrl);

      // Delete the photo
      await storageRef.delete();

      final userRef =
          FirebaseFirestore.instance.collection('users_list').doc(userId);
      await userRef.update({'profileImageUrl': ''});
      // setState(() {
      //   _imageprofile = '';
      //   _profileImage = null;
      // });

      print('Photo deleted successfully');
    } catch (e) {
      print('Error deleting photo: $e');
      // Handle the error accordingly
    }
  }

  Future<void> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users_list")
        .doc(widget.user!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _firstName = userDoc['first_name'];
        _lastName = userDoc['last_name'];
        _phone = userDoc['phone'];
        _imageprofile = userDoc['profileImageUrl'];

        _firstNameController.text = _firstName!;
        _lastNameController.text = _lastName!;
        _phoneController.text = _phone!;
      });
    }
  }

  Future<void> _saveUserData() async {
    await FirebaseFirestore.instance
        .collection("users_list")
        .doc(widget.user!.uid)
        .update({
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'phone': _phoneController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile updated successfully!'),
      backgroundColor: Color.fromARGB(255, 94, 93, 93),
      padding: EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      width: 300,
      elevation: 30,
      duration: Duration(milliseconds: 3000),
    ));

    setState(() {
      _firstName = _firstNameController.text;
      _lastName = _lastNameController.text;
      _phone = _phoneController.text;

      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isEditing)
              Column(
                children: [
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            hexStringToColor("55d0ff"),
                            hexStringToColor("00acdf"),
                            hexStringToColor("0080bf")
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                      //color: Color.fromARGB(255, 66, 145, 236),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        SizedBox(height: 0),
                        // GestureDetector(onTap: () {
                        //   pickUploadImage();
                        // }),
////////////////////////////////////////////////

                        Center(
                          child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Choose Image Source'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _pickProfileImage(
                                                ImageSource.gallery);
                                          },
                                          child: Text('Gallery'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _pickProfileImage(
                                                ImageSource.camera);
                                          },
                                          child: Text('Camera'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            deletePhotoFromFirebase(
                                                _profileImageUrl!,
                                                widget.user!.uid);
                                          },
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                _profileImage != null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundImage:
                                            FileImage(_profileImage!),
                                        //backgroundColor: Colors.white70,
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: _imageprofile != null
                                            ? NetworkImage(_imageprofile!)
                                            : null,
                                        backgroundColor: Colors.white,

                                        //backgroundColor: Colors.white70,
                                      ),
                                if (_profileImageUrl == '')
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                              ])),
                        ),
                        SizedBox(
                          height: 20,
                        ),
//////////////////////////////////////////////
                        Text(
                          'First Name : ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_firstName ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Last Name :',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_lastName ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Phone : ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${_phone ?? ''}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(90)),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: Text(
                              'Edit Profile',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 27, 129, 247),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.white38;
                                  }
                                  return Colors.white;
                                }),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (_isEditing)
              Column(
                children: [
                  SizedBox(height: 30),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                  ),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(0, 10, 5, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                          ),
                          child: ElevatedButton(
                            onPressed: _saveUserData,
                            child: Text(
                              'Save',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.white38;
                                }
                                return Colors.blue;
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(5, 10, 0, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            child: Text(
                              'Back',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.white38;
                                }
                                return Colors.blue;
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
