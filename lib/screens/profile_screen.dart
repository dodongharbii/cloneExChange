// ignore_for_file: prefer_const_constructors
// import 'dart:js';

import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:powerrangers_exchange/components/more_button.dart';
import 'package:powerrangers_exchange/components/profile_menu.dart';
import 'package:powerrangers_exchange/model/post_container.dart';
import 'package:powerrangers_exchange/model/profile_menu.dart';
import 'package:powerrangers_exchange/model/user_model.dart';
import 'package:powerrangers_exchange/screens/create_post_screen.dart';
import 'package:powerrangers_exchange/screens/edit_post_screen.dart';
import 'package:powerrangers_exchange/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  bool isEmpty = false;
  final storage = new FlutterSecureStorage();
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');

  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  checkPostsField() {
    usersRef.doc(loggedInUser.uid).get().then((doc) {
      if (doc.data().toString().contains('posts')) {
        if (doc['posts'].isNotEmpty) {
          if (this.mounted) {
            setState(() {
              isEmpty = false;
            });
          }
        } else {
          if (this.mounted) {
            setState(() {
              isEmpty = true;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Material(
            elevation: 5,
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              color: Colors.yellow[50],
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.yellowAccent[700],
                        child: Text(
                          loggedInUser.firstName != null &&
                                  loggedInUser.secondName != null
                              ? "${loggedInUser.firstName?[0].toUpperCase()}"
                                  "${loggedInUser.secondName?[0].toUpperCase()}"
                              : "",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loggedInUser.firstName != null &&
                                    loggedInUser.secondName != null
                                ? "${loggedInUser.firstName} ${loggedInUser.secondName}"
                                : "",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            loggedInUser.email != null
                                ? "${loggedInUser.email}"
                                : "",
                            style: TextStyle(
                                fontSize: 15, fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      SizedBox(
                        width: 50,
                        child: profileMenuButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 45,
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostUploadImageScreen(
                                selectedExchangeOption: '')));
                  },
                  icon: SizedBox(child: Image.asset('assets/write_post.png')),
                ),
                SizedBox(width: 5),
                Text(
                  'Write a post...',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('userID', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  checkPostsField();
                  return Expanded(
                    child: isEmpty
                        ? Column(
                            children: <Widget>[
                              SizedBox(
                                height: 25,
                              ),
                              Image.asset(
                                'assets/empty_post.png',
                                height: 300,
                                width: 300,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                                child: Text(
                                  'Looks like you haven\'t created any post yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children:
                                snapshot.data.docs.map<Widget>((document) {
                              return getPostContainer(
                                  context,
                                  document,
                                  MoreButton(
                                      document: document, context: context));
                            }).toList(),
                          ),
                  );
                }
              }),
        ],
      ),
    );
  }

  // Widget postMenuButton(document) {
  //   return SizedBox(
  //     width: 50,
  //     child: PopupMenuButton<MenuItem>(
  //       onSelected: (item) => onSelected(context, item, document),
  //       itemBuilder: (context) => [
  //         ...ProfileMenu.postItems.map(buildItem).toList(),
  //       ],
  //     ),
  //   );
  // }

  Widget profileMenuButton() {
    return PopupMenuButton<MenuItem>(
      child: Icon(Icons.settings),
      onSelected: (item) => onProfMenuSelected(context, item, null),
      itemBuilder: (context) => [
        ...ProfileMenu.userItems.map(buildItem).toList(),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Row(
          children: [
            Icon(item.icon, size: 15),
            const SizedBox(
              width: 10,
            ),
            Text(item.text),
          ],
        ),
      );

  // void onSelected(BuildContext context, MenuItem item, document) {
  //   switch (item) {
  //     case ProfileMenu.postEdit:
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //             builder: (context) => EditPostScreen(document: document)),
  //       );
  //       break;
  //     case ProfileMenu.postDelete:
  //       deletePost(document);
  //       break;
  //     case ProfileMenu.profileEdit:
  //       break;
  //     case ProfileMenu.signOut:
  //       logoutUser();
  //       break;
  //   }
  // }

  void onProfMenuSelected(BuildContext context, MenuItem item, document) {
    switch (item) {
      case ProfileMenu.profileEdit:
        break;
      case ProfileMenu.signOut:
        logoutUser();
        break;
    }
  }

  // deletePost(document) {
  //   showAlertDialog(context, document);
  // }

  // void showAlertDialog(BuildContext context, document) {
  //   Widget noButton = TextButton(
  //     style: TextButton.styleFrom(
  //       backgroundColor: Colors.grey.withOpacity(0.1),
  //     ),
  //     child: Text(
  //       "No",
  //       style: TextStyle(
  //         color: Colors.grey,
  //         fontSize: 15,
  //       ),
  //     ),
  //     onPressed: () {
  //       Navigator.of(context).pop(() {});
  //     },
  //   );

  //   Widget yesButton = TextButton(
  //     style: TextButton.styleFrom(
  //       backgroundColor: Colors.grey.withOpacity(0.1),
  //     ),
  //     child: Text(
  //       "Yes",
  //       style: TextStyle(
  //         color: Colors.redAccent,
  //         fontSize: 15,
  //       ),
  //     ),
  //     onPressed: () {
  //       //delete document from database
  //       postsRef.doc(document['postID']).delete();
  //       usersRef.doc(loggedInUser.uid).update({
  //         "posts": FieldValue.arrayRemove([document['postID']])
  //       });
  //       Fluttertoast.showToast(msg: "Post successfully deleted");
  //       Navigator.of(context).pop();
  //     },
  //   );

  //   AlertDialog alert = AlertDialog(
  //     content: Text(
  //       'Are you sure you want to delete this post?',
  //     ),
  //     actions: [
  //       noButton,
  //       yesButton,
  //     ],
  //   );

  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return alert;
  //       });
  // }

  logoutUser() async => {
        await FirebaseAuth.instance.signOut(),
        await storage.delete(key: "uid"),
        Fluttertoast.showToast(msg: "You have logged out"),
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (route) => false)
      };
}
