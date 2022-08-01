import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerrangers_exchange/screens/feeds_screen.dart';
import 'package:powerrangers_exchange/screens/messages_screen.dart';
import 'package:powerrangers_exchange/screens/profile_screen.dart';
import 'package:powerrangers_exchange/screens/saves_screen.dart';
import 'package:powerrangers_exchange/screens/search_post_screen.dart';

import '../components/cust_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueChanged<int> onChange;
  int selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: SizedBox(
              height: 40,
              child: Image.asset('assets/logo.png'),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     builder: (context) => SearchPostScreen()));
                  showSearch(
                    context: context,
                    delegate: MySearchDelegate(),
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              CustNavBar(
                  iconList: [
                    Icons.home_outlined,
                    Icons.messenger_outline,
                    Icons.bookmark_outline,
                    Icons.person_outline,
                  ],
                  defaultSelectedIndex: 0,
                  onChange: (val) {
                    setState(() {
                      selectedItem = val;
                    });
                  }),
              getHomePageScreen(selectedItem),
            ],
          )),
    );
  }

  getHomePageScreen(int selectedItem) {
    switch (selectedItem) {
      case 0:
        return FeedsScreen();
      case 1:
        return MessagesScreen();
      case 2:
        return SavesScreen();
      case 3:
        return ProfileScreen();
    }
  }
}
