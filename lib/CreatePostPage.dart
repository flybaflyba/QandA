
import 'dart:async';
import 'dart:html' as Html;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_web_image_picker/flutter_web_image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreatePostPage extends StatefulWidget{

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>{

  TextEditingController titleTextEditingController = new TextEditingController();

  var title = "";
  var content = "";

  List<Asset> imageAssets = List<Asset>();
  List<File> imageFiles = List<File>();
  String _error = 'No Error Detected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    var loopTimes = imageAssets.length + 1;
    if (imageAssets.length == 9) {
      loopTimes = 9;
    }
    return GridView.count(
      physics: ScrollPhysics(), // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(loopTimes, (index) {
        if (index == imageAssets.length) {
          // loop again after all images, add a icon button in the end
          return
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  if(kIsWeb) {
                    print("web");
                    final image = await FlutterWebImagePicker.getImage;
                    setState(() {
                      imageAssets.add(image as Asset);
                    });
                  } else {
                    print("app");
                    loadAssets();
                  }

                }
            );
        } else {
          Asset asset = imageAssets[index];
          return Stack(
            children: [
              AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
              // IconButton(
              //   iconSize: 25,
              //     color: Colors.white,
              //     icon: Icon(Icons.circle),
              //     onPressed: () {
              //     }
              // ),
              IconButton(
                iconSize: 20,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      imageAssets.removeAt(index);
                    });
                  }
              )
            ],
          );
        }
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 9,
        enableCamera: true,
        selectedAssets: imageAssets,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (resultList.length != 0) {
        imageAssets = resultList;
      }
      _error = error;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView(
            children: [
              Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
                child: Column(
                  children: [
                    SizedBox(height: 20,),

                    Container(
                      margin: EdgeInsets.all(20),
                      child:
                      TextField(
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                        onChanged: (value){
                          title = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Title",
                          alignLabelWithHint: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.all(20),
                      child:
                      TextField(
                        minLines: 1,
                        maxLines: 100,
                        textAlign: TextAlign.left,
                        onChanged: (value){
                          content = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Content",
                          alignLabelWithHint: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),

                    // Container(
                    //   margin: EdgeInsets.all(20),
                    //   child:
                    //   Column(
                    //     children: <Widget>[
                    //       Center(child: Text('Error: $_error')),
                    //       RaisedButton(
                    //         child: Text("Pick images"),
                    //         onPressed: loadAssets,
                    //       ),
                    //
                    //     ],
                    //   ),
                    // ),

                    Container(
                      margin: EdgeInsets.all(20),
                      child: buildGridView(),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 60,
                          width: 120,
                          child: RaisedButton(
                            onPressed: () {

                              // print(images);
                              if (title != "" && content != "") {
                                Post post = new Post(
                                  title: title,
                                  content: content,
                                  author: FirebaseAuth.instance.currentUser.email,
                                  createdTime: DateTime.now().toString(),
                                  images: imageAssets,
                                );
                                post.printOut();
                                post.create();
                              } else {
                                UniversalFunctions.showToast("Please complete both title and content.", UniversalValues.toastMessageTypeWarningColor);
                              }
                            },
                            color: UniversalValues.buttonColor,
                            child: Text(
                              'Create',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }}