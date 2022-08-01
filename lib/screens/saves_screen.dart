import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/model/post_container.dart';
import 'package:powerrangers_exchange/screens/feeds_screen.dart';
import 'package:powerrangers_exchange/components/message_save_button.dart';
import 'package:powerrangers_exchange/components/more_button.dart';

class SavesScreen extends StatefulWidget {
  const SavesScreen({Key? key}) : super(key: key);

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');
  User? currentUser = FirebaseAuth.instance.currentUser;
  List savedPosts = [];
  bool isEmpty = false;

  checkSavesField() {
    usersRef.doc(currentUser!.uid).get().then((doc) {
      if (doc.data().toString().contains('saves')) {
        if (doc['saves'].isNotEmpty) {
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
    usersRef.doc(currentUser!.uid).get().then((value) {
      if (this.mounted) {
        setState(() {
          savedPosts = value['saves'];
        });
      }
    });
    return Expanded(
        child: Column(
      children: <Widget>[
        SizedBox(height: 10),
        StreamBuilder(
            stream: postsRef.snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                checkSavesField();
                return Expanded(
                  child: isEmpty
                      ? SizedBox(
                          height: 600,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_add_outlined,
                                size: 250,
                                color: Colors.grey[200],
                              ),
                              SizedBox(height: 20),
                              Text('You have no saved posts.',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                        )
                      : ListView(
                          children: snapshot.data.docs.map<Widget>((document) {
                            return savedPosts.contains(document['postID'])
                                ? getPostContainer(context,
                                    document,
                                    document['userID'] == currentUser!.uid
                                        ? MoreButton(
                                            document: document,
                                            context: context,
                                          )
                                        : PostButtons(document: document))
                                : SizedBox();
                          }).toList(),
                        ),
                );
              }
            }),
      ],
    ));
  }
}
