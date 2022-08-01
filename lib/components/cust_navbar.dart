import 'package:flutter/material.dart';

class CustNavBar extends StatefulWidget {
  const CustNavBar(
      {Key? key,
      required this.iconList,
      required this.defaultSelectedIndex,
      required this.onChange})
      : super(key: key);

  final List<IconData> iconList;
  final int defaultSelectedIndex;
  final Function(int) onChange;

  @override
  State<CustNavBar> createState() => _CustNavBarState();
}

class _CustNavBarState extends State<CustNavBar> {
  List<IconData> iconList = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    iconList = widget.iconList;
    selectedIndex = widget.defaultSelectedIndex;
  }

  Widget buildNavBar(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        widget.onChange(index);
        setState(() {
          selectedIndex = index;
        });
      },
      child: Stack(
        children: [
          Container(
            height: 55,
            width: MediaQuery.of(context).size.width / iconList.length,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Icon(icon,
                size: 30,
                color: index == selectedIndex ? Colors.black : Colors.black38),
          ),
          Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            height: 55,
            width: (MediaQuery.of(context).size.width / iconList.length) - 50,
            decoration: BoxDecoration(
              border: index == selectedIndex
                  ? const Border(
                      bottom: BorderSide(width: 2, color: Colors.black))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> navBarItemList = [];

    for (int i = 0; i < iconList.length; i++) {
      navBarItemList.add(buildNavBar(iconList[i], i));
    }

    return Row(
      children: navBarItemList,
    );
  }
}
