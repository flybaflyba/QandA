
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:nice_button/nice_button.dart';
import 'package:qanda/BlankPages.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qanda/UniversalWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget{
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>{

  TextEditingController titleTextEditingController = new TextEditingController();
  TextEditingController contentTextEditingController = new TextEditingController();
  TextEditingController courseTextEditingController = new TextEditingController();

  var course = "";
  var title = "";
  var content = "";
  var topic = "What are Your Posting for?";

  List<bool> topicSelectionList = [false, false];
  var workInProgress = false;

  List<Asset> imageAssets = List<Asset>();
  List<Uint8List> imageUint8Lists = List<Uint8List>();
  String _error = 'No Error Detected';

  @override
  void initState() {
    super.initState();
  }

  void resetCreatePostPageFields() {
   setState(() {
     titleTextEditingController.text = "";
     contentTextEditingController.text = "";
     courseTextEditingController.text = "";
     title = "";
     content = "";
     topic = "What are Your Posting for?";
     topicSelectionList = [false, false];
     workInProgress = false;
     imageAssets.clear();
     imageUint8Lists.clear();
   });
  }

  Widget buildGridView() {
    var loopTimes = imageUint8Lists.length + 1;
    if (imageUint8Lists.length >= 9) {
      loopTimes = 9;
      if(imageUint8Lists.length > 9) {
        imageUint8Lists.removeRange(9, imageUint8Lists.length);
        UniversalFunctions.showToast("Maximum 9 Images", UniversalValues.toastMessageTypeWarningColor);
      }
    }
    // print(imageUint8Lists.length);
    return GridView.count(
      physics: ScrollPhysics(), // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(loopTimes, (index) {
        if (index == imageUint8Lists.length) {
          // loop again after all images, add a icon button in the end
          return
            Container(
              color: Colors.grey[200],
              child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // hide keyboard when pick images
                    FocusScope.of(context).requestFocus(new FocusNode()); // do not show keyboard
                    if(kIsWeb) {
                      print("web");
                      loadImagesOnWeb();
                    } else {
                      print("app");
                      loadImagesOnDevices();
                    }
                  }
              ),
            );
        } else {
          // Asset asset = imageAssets[index];
           Uint8List imageValue = imageUint8Lists[index];
          return Stack(
            children: [
              // AssetThumb(
              //   asset: asset,
              //   width: 300,
              //   height: 300,
              // ),
              Container(
                child: Image.memory(imageValue, fit: BoxFit.cover,),
                width: 300,
                height: 300,
              ),
              IconButton(
                iconSize: 20,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      imageUint8Lists.removeAt(index);
                      // imageAssets is only use on phones
                      if(!kIsWeb){
                        imageAssets.removeAt(index);
                      }
                    });
                  }
              )
            ],
          );
        }
      }),
    );
  }

  Future<void> loadImagesOnDevices() async {
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

    List<Uint8List> imageUint8ListsTemp = List<Uint8List>();
    for (Asset imageAsset in resultList) {
      final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);

      File imageFile = File(filePath);
      if (imageFile.existsSync()) {
        print(imageAsset.toString() + " --- converted image asset to file --- " + imageFile.toString());
      }
      Uint8List bytes = imageFile.readAsBytesSync();
      imageUint8ListsTemp.add(bytes);
    }
    
    setState(() {
      if (resultList.length != 0) {
        imageAssets = resultList;
        imageUint8Lists = imageUint8ListsTemp;
      }
      _error = error;
    });
  }

  Future<void> loadImagesOnWeb() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']);

    if (result != null) {
      // cannot use path, does not support on web https://github.com/miguelpruivo/flutter_file_picker/issues/591
      // List<File> files = result.paths.map((path) => File(path)).toList();
      // File file = File(result.paths.first);

      // print(result.files.first);
      Uint8List imageValue = result.files.first.bytes;
      // File imageFile = File.fromRawPath(imageValue); // uses dart.io, not supported on web

      List<Uint8List> imageUint8ListsTemp = result.files.map((file) => file.bytes).toList();

      setState(() {
        // imageFiles = files;
        imageUint8Lists = imageUint8ListsTemp;
      });

    } else {
      // User canceled the picker
    }
  }

  Future<void> savePost() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // prefs.setString("userName", "");

    var userName = prefs.get("userName");

    print(userName);

    if(userName == "" || userName == null) {
      print("missing user name");
      UniversalFunctions.askForUserMissingInfo(context, true, "Tell us who is posting?");
    } else {
      print("saving post now");
      var currentUserEmail = FirebaseAuth.instance.currentUser.email;
      var currentTimeInUtc = DateTime.now().toUtc();
      var currentTimeInUtcString = currentTimeInUtc.toString().split(".")[0];
      var postDocName = currentTimeInUtcString + " by " + currentUserEmail;
      print(postDocName);

      Post post = new Post(
        title: title,
        content: content,
        authorEmail: currentUserEmail,
        author: userName,
        postDocName: postDocName,
        topic: topic,
        course: course,
        createdTime: currentTimeInUtc, // with timezone info
        imageUint8Lists: imageUint8Lists,
      );
      post.printOut();

      print("start saving post to database");
      setState(() {
        workInProgress = true;
      });
      post.create()
          .then((value) {
        print("finish saving post");
        setState(() {
          workInProgress = false;
        });
        resetCreatePostPageFields();
        Navigator.pop(context);
        // push to a new page
        Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocTypePath: post.topic.toLowerCase() + " posts", postDocName: post.postDocName,),));
      });

    }


  }


  Widget listMatchedCourses(String enteredString)
  {

    print(enteredString);
    List<dynamic> filteredCourses = new List<dynamic>();
    setState(() {
      for(var i = UniversalValues.courses.length - 1; i > -1; i--){
        if (UniversalValues.courses[i].contains(enteredString.toUpperCase())) {
          if(course != UniversalValues.courses[i]) {
            filteredCourses.add(UniversalValues.courses[i]);
          }
        }
      }
      if(filteredCourses.length == 0 && !UniversalValues.courses.contains(enteredString.toUpperCase())) {
        filteredCourses.add("No Course Found");
      }
    });

    // print(filteredCourses.length);
    List<Widget> list = new List<Widget>();
    if (enteredString != "") {
      for(var i = filteredCourses.length - 1; i > -1; i--){
        //list.add(new Text(strings[i]));
        String temp = filteredCourses[i];
        list.add(
          Container(
            margin: EdgeInsets.all(5),
            child: Center(
              child: FlatButton(
                textColor: Colors.blueAccent,
                onPressed: () {
                  if (temp != "No Course Found") {
                    setState(() {
                      course = temp;
                      courseTextEditingController.text = temp;
                    });
                  }
                  },
                child: Text(
                  temp,
                ),
              ),
            ),
          ),
        );
      }
    }


    return new ListView(
      shrinkWrap: true,
      children: list,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Create Post"),),
      ),
      body:
      // disable screen touch and show progress indicator when work in progress
      AbsorbPointer(
        absorbing: workInProgress,
        child: Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: Stack(
                children: [
                  ListView(
                    children: [

                      UniversalWidgets.titleWidget(topic),

                      Center(
                        child: ToggleButtons(
                          children: <Widget>[
                            Icon(Icons.nightlife),
                            Icon(Icons.school),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              for (int buttonIndex = 0; buttonIndex < topicSelectionList.length; buttonIndex++) {
                                if (buttonIndex == index) {
                                  topicSelectionList[buttonIndex] = !topicSelectionList[buttonIndex];
                                } else {
                                  topicSelectionList[buttonIndex] = false;
                                }
                              }
                              if(index == 0) {
                                setState(() {
                                  topic = "Campus Life";
                                });
                              } else {
                                setState(() {
                                  topic = "Academic";
                                });
                              }
                              // print(index);
                            });
                          },
                          isSelected: topicSelectionList,
                        ),
                      ),

                      topic == "Academic" ?

                      Container(
                          margin: EdgeInsets.all(20),
                          child:
                          Column(
                            children: [
                              TextField(
                                controller: courseTextEditingController,
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                                onChanged: (value){
                                  setState(() {
                                     course = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Course",
                                  alignLabelWithHint: true,
                                  // focusedBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                  // ),
                                  // enabledBorder: OutlineInputBorder(
                                  //   borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                  // ),
                                ),
                              ),
                              Container(
                                color: Colors.grey[300],
                                constraints: BoxConstraints(minHeight: 0, maxHeight: 200),
                                child: listMatchedCourses(course),
                              )
                            ],
                          )
                      )


                      :
                      SizedBox(height: 0,),



                      Container(
                        margin: EdgeInsets.all(20),
                        child:
                        Column(
                          children: [
                            title != "" ? Container(margin: EdgeInsets.only(bottom: 5), child: Center(child: Text("Title",),),) : SizedBox(height: 0,),
                            TextField(
                              controller: titleTextEditingController,
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.center,
                              onChanged: (value){
                                setState(() {
                                  title = value;
                                });
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
                          ],
                        )
                      ),

                      Container(
                        margin: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            content != "" ? Container(margin: EdgeInsets.only(bottom: 5), child: Center(child: Text("Content",),),) : SizedBox(height: 0,),
                            TextField(
                              controller: contentTextEditingController,
                              minLines: 1,
                              maxLines: 100,
                              textAlign: TextAlign.left,
                              onChanged: (value){
                                setState(() {
                                  content = value;
                                });

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
                          ],
                        )
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


                      Container(
                          margin: EdgeInsets.all(20),
                          child:   Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NiceButton(
                                width: 255,
                                elevation: 8.0,
                                radius: 52.0,
                                text: "Post",
                                background: UniversalValues.buttonColor,
                                onPressed: () {
                                  // print(images);
                                  // print(titleTextEditingController.text);
                                  // print(titleTextEditingController.value);
                                  if (title != "" && content != "" && topic != "What are Your Posting for?") {

                                    if(topic == "Academic") {
                                      if (!UniversalValues.courses.contains(course)) {
                                        UniversalFunctions.showToast("Please search/select a course.", UniversalValues.toastMessageTypeWarningColor);
                                      } else {
                                        // save post
                                        savePost();
                                      }
                                    } else {
                                      //save post
                                      savePost();
                                    }


                                  } else {
                                    if (title == "") {
                                      UniversalFunctions.showToast("What's the title?", UniversalValues.toastMessageTypeWarningColor);
                                    } else if (content == "") {
                                      UniversalFunctions.showToast("Please provide some content.", UniversalValues.toastMessageTypeWarningColor);
                                    } else {
                                      UniversalFunctions.showToast("What are you posting for?", UniversalValues.toastMessageTypeWarningColor);
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                      ),

                    ],
                  ),
                  Center(
                    child: workInProgress
                        ?
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          backgroundColor: UniversalValues.primaryColor,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                          strokeWidth: 10,
                        ),
                        SizedBox(height: 15,),
                        LinearProgressIndicator(
                          backgroundColor: UniversalValues.primaryColor,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                          minHeight: 10,
                        )
                      ],
                    )
                        :
                    SizedBox(height: 0,),)
                ],
              )
          ),
        )

      )



    );
  }}