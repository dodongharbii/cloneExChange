// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/components/message_container.dart';
import 'package:powerrangers_exchange/screens/visit_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.senderID, required this.document})
      : super(key: key);

  final String senderID;
  final document;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final usersRef = FirebaseFirestore.instance.collection('users');

  void sendMessage() {
    FocusScope.of(context).unfocus();
    String message = messageController.text;
    messageController.clear();
    storeSenderMessage(message);
    storeRecipientMessage(message);
  }

  void storeSenderMessage(message) async {
    await usersRef
        .doc(widget.senderID)
        .collection('messages')
        .doc(widget.document['userID'])
        .collection('chats')
        .add({
      "senderID": widget.senderID,
      "recipientID": widget.document['userID'],
      "message": message,
      "date": DateTime.now(),
    }).then((value) {
      usersRef
          .doc(widget.senderID)
          .collection('messages')
          .doc(widget.document['userID'])
          .set({
        'recentMsg': message,
      });
    });
  }

  void storeRecipientMessage(message) async {
    await usersRef
        .doc(widget.document['userID'])
        .collection('messages')
        .doc(widget.senderID)
        .collection('chats')
        .add({
      "senderID": widget.senderID,
      "recipientID": widget.document['userID'],
      "message": message,
      "date": DateTime.now(),
    }).then((value) {
      usersRef
          .doc(widget.document['userID'])
          .collection('messages')
          .doc(widget.senderID)
          .set({
        'recentMsg': message,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 0,
        leading: IconButton(
          icon: SizedBox(
            height: 25,
            child: Image.asset("assets/back_arrow.png"),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  // document['userID'] != currentUser!.uid
                  //     ?
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => VisitProfileScreen(
                                userID: widget.document['userID'],
                              ))));
                  // : Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: ((context) => ProfileScreen())));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        widget.document['userFName'][0] != null &&
                                widget.document['userLName'][0] != null
                            ? widget.document['userFName'][0].toUpperCase() +
                                widget.document['userLName'][0].toUpperCase()
                            : "",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      widget.document['userFName'] +
                          " " +
                          widget.document['userLName'],
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: StreamBuilder(
                stream: usersRef
                    .doc(widget.senderID)
                    .collection('messages')
                    .doc(widget.document['userID'])
                    .collection('chats')
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.data.docs.length < 1) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/wave_hand.png',
                              height: 150,
                              color: Colors.yellow[200],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Type your first message!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              "It's time to start a chat",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          reverse: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            bool isCurrentUser = snapshot.data.docs[index]
                                    ['senderID'] ==
                                widget.senderID;
                            return MessageContainer(
                                message: snapshot.data.docs[index]['message'],
                                isCurrentUser: isCurrentUser);
                          });
                    }
                  }
                },
              ),
            ),
          ),
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10, right: 10),
                      hintText: 'Write your message here',
                      hintStyle: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black38),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.yellow,
                        size: 25,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
