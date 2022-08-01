import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/screens/chat_screen.dart';

class PostButtons extends StatefulWidget {
  PostButtons({
    Key? key,
    this.document,
    this.option,
  }) : super(key: key);

  final document;
  final option;

  @override
  State<PostButtons> createState() => _PostButtonsState();
}

class _PostButtonsState extends State<PostButtons> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  final postsRef = FirebaseFirestore.instance.collection('posts');
  var userDoc;
  List userSaves = [];
  User? currentUser = FirebaseAuth.instance.currentUser;

  bool isSaved = false;

  void initState() {
    super.initState();
    userDoc = usersRef.doc(currentUser!.uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                    senderID: currentUser!.uid, document: widget.document)));
          },
          child:
              Icon(Icons.message_outlined, color: Colors.grey[700], size: 25),
        ),
      ),
      Container(
        width: 40,
        child: TextButton(
          onPressed: () {
            usersRef.doc(currentUser!.uid).get().then((DocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>;

              updateDataInFirebase(data);
            });
          },
          child: widget.document['savesStatus'][currentUser!.uid] == true
              ? Icon(
                  Icons.bookmark_remove,
                  color: Colors.yellow[700],
                  size: 27,
                )
              : Icon(
                  Icons.bookmark_add_outlined,
                  color: Colors.grey[700],
                  size: 27,
                ),
        ),
      ),
    ]);
  }

  updateDataInFirebase(data) {
    if (data['saves'].contains(widget.document['postID'])) {
      userDoc.update({
        "saves": FieldValue.arrayRemove([widget.document['postID']])
      });
      postsRef
          .doc(widget.document['postID'])
          .update({"savesStatus.${currentUser!.uid}": false});
      postsRef
          .doc(widget.document['postID'])
          .update({"saves": widget.document['saves'] - 1});
      setState(() {
        isSaved = false;
      });
    } else {
      userDoc.update({
        "saves": FieldValue.arrayUnion([widget.document['postID']])
      });
      postsRef
          .doc(widget.document['postID'])
          .update({"savesStatus.${currentUser!.uid}": true});
      postsRef
          .doc(widget.document['postID'])
          .update({"saves": widget.document['saves'] + 1});
      setState(() {
        isSaved = true;
      });
    }
  }
}
