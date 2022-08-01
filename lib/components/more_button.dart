import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:powerrangers_exchange/components/profile_menu.dart';
import 'package:powerrangers_exchange/model/profile_menu.dart';
import 'package:powerrangers_exchange/screens/edit_post_screen.dart';

class MoreButton extends StatelessWidget {
  MoreButton({Key? key, this.document, this.context}) : super(key: key);

  final document;
  final context;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: PopupMenuButton<MenuItem>(
        onSelected: (item) => onSelected(context, item, document),
        itemBuilder: (context) => [
          ...ProfileMenu.postItems.map(buildItem).toList(),
        ],
      ),
    );
  }

  void onSelected(BuildContext context, MenuItem item, document) {
    switch (item) {
      case ProfileMenu.postEdit:
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => EditPostScreen(document: document)),
        );
        break;
      case ProfileMenu.postDelete:
        deletePost(document);
        break;
    }
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

  deletePost(document) {
    showAlertDialog(context, document);
  }

  void showAlertDialog(BuildContext context, document) {
    Widget noButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
      child: Text(
        "No",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop(() {});
      },
    );

    Widget yesButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
      child: Text(
        "Yes",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 15,
        ),
      ),
      onPressed: () {
        //delete document from database
        postsRef.doc(document['postID']).delete();
        usersRef.doc(currentUser!.uid).update({
          "posts": FieldValue.arrayRemove([document['postID']])
        });
        Fluttertoast.showToast(msg: "Post successfully deleted");
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        'Are you sure you want to delete this post?',
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
