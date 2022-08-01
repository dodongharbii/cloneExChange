import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:powerrangers_exchange/screens/home_screen.dart';
import 'package:uuid/uuid.dart';

class PostUploadImageScreen extends StatefulWidget {
  const PostUploadImageScreen({Key? key, this.selectedExchangeOption})
      : super(key: key);
  final selectedExchangeOption;

  @override
  State<PostUploadImageScreen> createState() => _PostUploadImageScreenState();
}

class _PostUploadImageScreenState extends State<PostUploadImageScreen> {
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final usersRef = FirebaseFirestore.instance.collection('users');
  final DateTime timestamp = DateTime.now();
  late firebase_storage.Reference ref;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();

  final List<XFile> images = [];
  final List<String> imgsUrl = [];
  late String currentUserFName;
  late String currentUserLName;
  bool isUploading = false;
  bool isPressed = false;
  int itemUploaded = 0;
  String appBarTitle = 'Sell';
  String chosenCategory = "Appliance";
  String exchangeOption = "Sell";
  String postID = Uuid().v4();
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
    if (widget.selectedExchangeOption != '') {
      exchangeOption = widget.selectedExchangeOption;
      appBarTitle = widget.selectedExchangeOption;
    }
  }

  Future<void> chooseFromGallery() async {
    List<XFile>? chosenFiles = await ImagePicker().pickMultiImage();

    setState(() {
      if (chosenFiles!.isNotEmpty) {
        images.addAll(chosenFiles);
      }
    });
  }

  void uploadService(List<XFile> img) {
    for (int i = 0; i < img.length; i++) {
      uploadFilesToFirebaseStorage(img[i]);
    }
  }

  Future<void> uploadFilesToFirebaseStorage(XFile img) async {
    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(img.path)}');

    firebase_storage.UploadTask uploadTask = ref.putFile(File(img.path));
    firebase_storage.TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() {
      setState(() {
        itemUploaded++;
      });
    });

    String imgUrl = await storageSnap.ref.getDownloadURL();

    setState(() {
      imgsUrl.add(imgUrl);
      if (itemUploaded == images.length) {
        usersRef.doc(currentUser!.uid).update({
          "posts": FieldValue.arrayUnion([postID])
        });

        final userPostData = {
          "postID": postID,
          "timeStamp": timestamp,
          "userID": currentUser!.uid,
          "userFName": currentUserFName,
          "userLName": currentUserLName,
          "postType": exchangeOption,
          "imgsUrl": imgsUrl,
          "caption": captionController.text,
          "location": locationController.text,
          "category": chosenCategory,
          "price": int.parse(priceController.text),
          "saves": 0,
          "savesStatus": {}
        };

        createPostInFireStore(userPostData);
        Fluttertoast.showToast(msg: "Successfully posted");
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HomeScreen()));
        Navigator.of(context).pop();
      }
    });
  }

  createPostInFireStore(userPostData) {
    postsRef.doc(postID).set(userPostData);
  }

  clearImage() {
    setState(() {
      images.clear();
    });
  }

  submitHandler() {
    if (_formKey.currentState!.validate() && images.isNotEmpty) {
      usersRef.doc(currentUser!.uid).get().then((value) {
        setState(() {
          currentUserFName = value.data()!['firstName'];
          currentUserLName = value.data()!['secondName'];
        });
      });
      setState(() {
        isUploading = true;
        isPressed = false;
      });
      uploadService(images);
    } else {
      setState(() {
        isUploading = false;
        isPressed = true;
      });
    }
  }

  Scaffold buildUploadForm() {
    dropdownItems.sort(((a, b) => a.toString().compareTo(b.toString())));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SizedBox(
            height: 25,
            child: Image.asset("assets/back_arrow.png"),
          ),
          onPressed: () {
            clearImage();
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(appBarTitle),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => submitHandler(),
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 17,
              ),
            ),
          )
        ],
      ),
      body: isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      'Uploading',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(
                    value: itemUploaded / images.length,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: images.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Center(
                                  child: IconButton(
                                    color: Colors.yellow,
                                    iconSize: 40,
                                    icon: Icon(Icons.add),
                                    onPressed: isUploading
                                        ? null
                                        : () => chooseFromGallery(),
                                  ),
                                )
                              : Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        File(images[index - 1].path),
                                        fit: BoxFit.cover,
                                        width: 250,
                                        height: 250,
                                      ),
                                      Positioned(
                                          right: 5,
                                          top: 5,
                                          child: InkWell(
                                            child: Icon(
                                              Icons.remove_circle,
                                              size: 25,
                                              color: Colors.yellow.shade400,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                images.removeAt(index - 1);
                                              });
                                            },
                                          )),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                  images.isEmpty && isPressed
                      ? Text(
                          'Please choose an image.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 199, 69, 67),
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        value: 'Sell',
                        groupValue: exchangeOption,
                        onChanged: (String? value) {
                          setState(() {
                            exchangeOption = value!;
                            appBarTitle = value;
                          });
                        },
                      ),
                      const Text(
                        "Sell",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Radio(
                        value: 'Barter',
                        groupValue: exchangeOption,
                        onChanged: (String? value) {
                          setState(() {
                            exchangeOption = value!;
                            appBarTitle = value;
                          });
                        },
                      ),
                      const Text(
                        "Barter",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: TextFormField(
                      controller: captionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.withOpacity(0.1),
                        filled: true,
                        hintText: "Write something about your item/s...",
                        border: InputBorder.none,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a caption for your post.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.pin_drop,
                      color: Colors.yellow,
                      size: 35,
                    ),
                    title: TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: "Type address or location here...",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide your location.';
                        }
                        return null;
                      },
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
                            return DropdownMenuItem(
                                child: Text(item), value: item);
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
                    title: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: exchangeOption == 'Sell'
                            ? "Type price"
                            : "Type trade value",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide price for your item/s.';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    locationController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUploadForm();
  }
}
