import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/components/message_save_button.dart';
import 'package:powerrangers_exchange/components/more_button.dart';
import 'package:powerrangers_exchange/model/post_container.dart';
import 'package:powerrangers_exchange/screens/feeds_screen.dart';

class MySearchDelegate extends SearchDelegate {
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool isSearching = false;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      query != '' && !isSearching
          ? IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                query = '';
              },
            )
          : Container(),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: SizedBox(
        height: 25,
        child: Image.asset("assets/back_arrow.png"),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    isSearching = true;
    return StreamBuilder<QuerySnapshot>(
        stream: postsRef.snapshots().asBroadcastStream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data!.docs
                    .where((QueryDocumentSnapshot<Object?> element) =>element['caption'].toString().toLowerCase().contains(query.toLowerCase()) ||element['category'].toString().toLowerCase() ==query.toLowerCase() ||element['location'].toString().toLowerCase().contains(query.toLowerCase())).isEmpty ||query == '') {
              return Center(
                child: query == ''
                    ? Text(
                        'Please enter a keyword.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        'Nothing found.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              );
            } else {
              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ...snapshot.data!.docs
                            .where((QueryDocumentSnapshot<Object?> element) =>
                                element['caption']
                                    .toString()
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                element['category'].toString().toLowerCase() ==
                                    query.toLowerCase() ||
                                element['location']
                                    .toString()
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                            .map((QueryDocumentSnapshot<Object?> data) {
                          return getPostContainer(context,
                              data,
                              data['userID'] == currentUser!.uid
                                  ? MoreButton(
                                      document: data,
                                      context: context,
                                    )
                                  : PostButtons(document: data));
                        }),
                      ],
                    ),
                  ),
                ],
              );
            }
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    isSearching = false;
    return Center(
      child: Text(
        "Search posts by entering keyword/s",
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
