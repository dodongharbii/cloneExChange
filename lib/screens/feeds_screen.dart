// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/components/message_save_button.dart';
import 'package:powerrangers_exchange/components/more_button.dart';
import 'package:powerrangers_exchange/screens/create_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerrangers_exchange/model/post_container.dart';
import 'package:powerrangers_exchange/screens/profile_screen.dart';
// import 'package:intl/intl_browser.dart';

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({Key? key}) : super(key: key);

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<bool> isSelected = [true, false];
  String selectedExchangeOption = 'Sell';
  int option = 0;
  bool isSaved = false;

  final users = FirebaseFirestore.instance.collection('users');
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(15),
              isSelected: isSelected,
              selectedColor: Colors.black,
              fillColor: Colors.yellow.shade300,
              color: Colors.grey,
              renderBorder: false,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Sell',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Barter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 2,
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              ],
              onPressed: (int newIndex) {
                setState(() {
                  for (int index = 0; index < isSelected.length; index++) {
                    if (index == newIndex) {
                      isSelected[index] = true;
                      if (index == 0) {
                        selectedExchangeOption = 'Sell';
                      } else {
                        selectedExchangeOption = 'Barter';
                      }
                    } else {
                      isSelected[index] = false;
                    }
                  }
                  option = newIndex;
                });
              },
            ),
          ),
          SizedBox(height: 10),
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
                                    selectedExchangeOption:
                                        selectedExchangeOption)))
                        .then((value) => setState(() {}));
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
          SizedBox(height: 10),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('postType', isEqualTo: option == 0 ? 'Sell' : 'Barter')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Expanded(
                    child: ListView(
                      children: snapshot.data.docs.map<Widget>((document) {
                        // DateFormat().format(postDateTime);
                        // PostButtons();
                        return getPostContainer(context,
                            document,
                            document['userID'] == currentUser!.uid
                                ? MoreButton(
                                    document: document,
                                    context: context,
                                  )
                                : PostButtons(
                                    document: document, option: option));
                      }).toList(),
                    ),
                  );
                }
              })
        ],
      ),
    );
  }
}
