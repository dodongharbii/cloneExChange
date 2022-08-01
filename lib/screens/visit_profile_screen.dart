// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:powerrangers_exchange/components/message_save_button.dart';
import 'package:powerrangers_exchange/components/more_button.dart';
import 'package:powerrangers_exchange/components/profile_menu.dart';
import 'package:powerrangers_exchange/model/post_container.dart';
import 'package:powerrangers_exchange/model/profile_menu.dart';
import 'package:powerrangers_exchange/model/user_model.dart';

class VisitProfileScreen extends StatefulWidget {
  const VisitProfileScreen({Key? key, required this.userID}) : super(key: key);

  final userID;

  @override
  State<VisitProfileScreen> createState() => _VisitProfileScreenState();
}

class _VisitProfileScreenState extends State<VisitProfileScreen> {
  String userFirstName = '';
  String userLastName = '';
  String userEmail = '';
  bool isEmpty = false;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');
  User? currentUser = FirebaseAuth.instance.currentUser;

  checkPostsField() {
    usersRef.doc(widget.userID).get().then((doc) {
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
    usersRef.doc(widget.userID).get().then((doc) {
      setState(() {
        userFirstName = doc['firstName'];
        userLastName = doc['secondName'];
        userEmail = doc['email'];
      });
    });
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: SizedBox(
              height: 25,
              child: Image.asset("assets/back_arrow.png"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: SizedBox(
            height: 40,
            child: Image.asset('assets/logo.png'),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Material(
              elevation: 5,
              child: Column(
                children: [
                  Container(
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
                              radius: 35,
                              backgroundColor: Colors.yellow.shade400,
                              child: Text(
                                userFirstName != '' && userLastName != ''
                                    ? "${userFirstName[0].toUpperCase()}"
                                        "${userLastName[0].toUpperCase()}"
                                    : "",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userFirstName + ' ' + userLastName,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                // SizedBox(height: 30, child: editProfileButton),
                              ],
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            // SizedBox(
                            //   width: 50,
                            //   child: PopupMenuButton<MenuItem>(
                            //     child: Icon(Icons.settings),
                            //     onSelected: (item) => onSelected(context, item, null),
                            //     itemBuilder: (context) => [
                            //       ...ProfileMenu.userItems.map(buildItem).toList(),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder(
                stream: postsRef
                    .where('userID', isEqualTo: widget.userID)
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
                          ? SizedBox(
                              height: 600,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.newspaper_outlined,
                                    size: 250,
                                    color: Colors.grey[200],
                                  ),
                                  SizedBox(height: 20),
                                  Text('This user has no posts available.',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic)),
                                ],
                              ),
                            )
                          : ListView(
                              children:
                                  snapshot.data.docs.map<Widget>((document) {
                                return getPostContainer(
                                    context,
                                    document,
                                    document['userID'] != currentUser!.uid
                                        ? PostButtons(document: document)
                                        : MoreButton(
                                            document: document,
                                            context: context,
                                          ));
                              }).toList(),
                            ),
                    );
                  }
                }),
          ],
        ));
  }
}
