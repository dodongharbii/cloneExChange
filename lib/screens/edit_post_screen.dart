import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:powerrangers_exchange/screens/profile_screen.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({Key? key, this.document}) : super(key: key);
  final document;
  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final postsRef = FirebaseFirestore.instance.collection('posts');
  bool isSaving = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var captionController = TextEditingController();
  var locationController = TextEditingController();
  var priceController = TextEditingController();

  String exchangeOption = "Sell";
  String chosenCategory = "Appliance";
  var dropdownItems = [
    "Furniture",
    "Books",
    "Technology",
    "Clothing",
    "Craft",
    "Appliance",
    "Health",
    "Beauty",
    "Sports",
    "Travel",
    "Toy",
    "Jewelry"
  ];

  void initState() {
    super.initState();
    setState(() {
      chosenCategory = widget.document['category'];
      captionController.text = widget.document['caption'];
      locationController.text = widget.document['location'];
      priceController.text = widget.document['price'].toString();
    });
  }

  saveHandler() {
    showAlertDialog(context);
  }

  void showAlertDialog(BuildContext context) {
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
        Navigator.of(context).pop();
      },
    );

    Widget yesButton = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
      child: Text(
        "Yes",
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 15,
        ),
      ),
      onPressed: () {
        setState(() {
          isSaving = true;
        });

        //update changes to database
        postsRef.doc(widget.document['postID']).update({
          "caption": captionController.text,
          "location": locationController.text,
          "category": chosenCategory,
          "price": int.parse(priceController.text),
        });
        Fluttertoast.showToast(msg: "Changes saved");
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text(
        'Are you sure you want to save your changes?',
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

  buildEditPostForm() {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: SizedBox(
              height: 25,
              child: Image.asset("assets/back_arrow.png"),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: const Text('Edit Post'),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => saveHandler(),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 17,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TextField(
                controller: captionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintMaxLines: 20,
                  fillColor: Colors.grey.withOpacity(0.1),
                  filled: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.pin_drop,
                color: Colors.yellow,
                size: 35,
              ),
              title: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.category_sharp,
                color: Colors.yellow,
                size: 35,
              ),
              title: Container(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    menuMaxHeight: 225,
                    isExpanded: true,
                    value: chosenCategory,
                    items: dropdownItems.map((String item) {
                      return DropdownMenuItem(child: Text(item), value: item);
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        chosenCategory = value!;
                      });
                    },
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/value.png',
                height: 35,
                color: Colors.yellow,
              ),
              title: TextField(
                controller: priceController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 17,
                ),
              ),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildEditPostForm();
  }
}
