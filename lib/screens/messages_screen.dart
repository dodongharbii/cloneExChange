// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/screens/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final usersRef = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder(
            stream: usersRef
                .doc(currentUser!.uid)
                .collection('messages')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshotMsg) {
              if (!snapshotMsg.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshotMsg.data.docs.length,
                    itemBuilder: (context, i) {
                      var document = snapshotMsg.data.docs;

                      return FutureBuilder(
                        future: usersRef.doc(document[i].id).get(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshotUser) {
                          var user = snapshotUser.data;

                          if (!snapshotUser.hasData) {}
                          return snapshotUser.hasData
                              ? ListTile(
                                  tileColor: Color.fromARGB(255, 255, 251, 221),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.yellow,
                                    child: Text(
                                      user['firstName'][0] != null &&
                                              user['secondName'][0] != null
                                          ? user['firstName'][0].toUpperCase() +
                                              user['secondName'][0]
                                                  .toUpperCase()
                                          : "",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user['firstName'] +
                                        ' ' +
                                        user['secondName'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    strutStyle: StrutStyle(fontSize: 12.0),
                                    text: TextSpan(
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                        text: document[i]['recentMsg']),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) => ChatScreen(
                                                senderID: currentUser!.uid,
                                                document: getUser(user)))));
                                  },
                                )
                              : SizedBox();
                        },
                      );
                    });
              }
            }));
  }

  getUser(user) {
    final userInfo = {
      'userFName': user['firstName'],
      'userLName': user['secondName'],
      'userID': user['uid']
    };

    return userInfo;
  }
}
