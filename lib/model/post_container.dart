// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/screens/profile_screen.dart';
import 'package:powerrangers_exchange/screens/visit_profile_screen.dart';

Container getPostContainer(BuildContext context, document, Widget postButtons) {
  Timestamp timeStamp = document['timeStamp'];
  DateTime postDateTime = timeStamp.toDate();

  return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.grey[200]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    // document['userID'] != currentUser!.uid
                    //     ?
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => VisitProfileScreen(
                                  userID: document['userID'],
                                ))));
                    // : Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: ((context) => ProfileScreen())));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: Text(
                      document['userFName'][0] != null &&
                              document['userLName'][0] != null
                          ? document['userFName'][0].toUpperCase() +
                              document['userLName'][0].toUpperCase()
                          : "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // document['userID'] != currentUser!.uid
                        //     ?
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => VisitProfileScreen(
                                      userID: document['userID'],
                                    ))));
                        // : Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: ((context) => ProfileScreen())));
                      },
                      child: Text(
                        document['userFName'] + " " + document['userLName'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      postDateTime.toString(),
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              postButtons
            ],
          ),
          SizedBox(height: 20),
          Text('Category: ' + document['category'],
              style: TextStyle(fontSize: 18)),
          Text('Location: ' + document['location'],
              style: TextStyle(fontSize: 18)),
          Text(
              (document['postType'] == 'Sell' ? 'Price: ' : 'Trade Value: ') +
                  document['price'].toString(),
              style: TextStyle(fontSize: 18)),
          Text('\n' + document['caption'], style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (int i = 0; i < document['imgsUrl'].length; i++)
                  Container(
                    padding: EdgeInsets.only(
                      left: 0,
                      right: 7,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.yellow[200],
                      ),
                      height: 250,
                      width: 250,
                      child: Image.network(
                        (document['imgsUrl'][i]).toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ])),
          SizedBox(
            height: document['saves'] > 0 ? 50 : 0,
            width: double.infinity,
            child: Center(
              child: Text(
                document['saves'] > 0
                    ? 'This post is saved by ' +
                        document['saves'].toString() +
                        (document['saves'] == 1 ? ' user.' : ' users.')
                    : '',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ));
}
