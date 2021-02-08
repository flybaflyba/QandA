
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:nice_button/nice_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qanda/customWidgets/TitleWidget.dart';
import 'package:qanda/models/Post.dart';
import 'package:qanda/pages/ShowPostPage.dart';
import 'package:qanda/pages/SignInUpPage.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreatePostPage extends StatefulWidget{

  CreatePostPage({Key key, this.post}) : super(key: key);

  Post post;

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
  List<Asset> imageAssets = List<Asset>();
  List<dynamic> imageUint8Lists = List<dynamic>();
  // Map thumbnailAndImageUrls = Map<dynamic, dynamic>();

  var workInProgress = false;
  String _error = 'No Error Detected';

  int countUrls() {
    int count = 0;
    for(var i in imageUint8Lists){
      if (i.runtimeType == String) {
        count ++;
      }
    }
    return count;
  }

  @override
  void initState() {
    super.initState();

    if (widget.post == null) {
      print("creating new post");
    } else {
      print("editing post");
      setState(() {
        topicSelectionList = [widget.post.topic == "Campus Life", widget.post.topic == "Academic"];

        if(widget.post.topic == "") {
          widget.post.topic = "What are Your Posting for?";
        }
        topic = widget.post.topic;
        course = widget.post.course;
        courseTextEditingController.text = course;
        content = widget.post.content;
        contentTextEditingController.text = content;
        title = widget.post.title;

        // TODO download images to local

        // downloadImages();

        for(String url in widget.post.thumbnailAndImageUrls.keys.toList()){
          imageUint8Lists.add(url);
          // imageAssets.add(null);
        }

      });
    }



    if (kIsWeb) {
      Fluttertoast.showToast(
          msg: "Image processing is extremely slow in browser, if you are uploading images, we suggest you upload smaller images, or use the app versions of our app",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: UniversalValues.toastMessageTypeWarningColor,
          webBgColor: "linear-gradient(to right, #cc00ff, #ff0000)",
          webPosition: "right",
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
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

  // void createThumbnails() {
  //   var dateTimeNow = DateTime.now();
  //   var dateTimeLast = DateTime.now();
  //
  //   List<Uint8List> imageUint8ListsTemp = new List<Uint8List>();
  //   imageUint8ListsTemp = imageUint8Lists;
  //
  //
  //   for(Uint8List i in imageUint8ListsTemp) {
  //     dateTimeNow = DateTime.now();
  //     print("start creating thumbnail");
  //     dateTimeLast = DateTime.now();
  //
  //     // create a thumbnail to store in the data base, we don't need the larger image every time
  //     imagePackage.Image image = imagePackage.decodeImage(i); // TODO this process of is taking long time only ON WEB
  //     dateTimeNow = DateTime.now();
  //     print("decoding image took " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
  //     dateTimeLast = DateTime.now();
  //     imagePackage.Image thumbnail = imagePackage.copyResize(image, width: 200);
  //     dateTimeNow = DateTime.now();
  //     print("resizing image took " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
  //     dateTimeLast = DateTime.now();
  //     Uint8List thumbnailUint8list = imagePackage.encodePng(thumbnail);
  //     thumbnailAndImageUrls[thumbnailUint8list] = i;
  //
  //     dateTimeNow = DateTime.now();
  //     print("end of creating thumbnail (encoding image took) " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
  //     dateTimeLast = DateTime.now();
  //   }
  //
  //   print(thumbnailAndImageUrls);
  // }

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
                      loadImagesOnWeb()
                          .then((value) => {

                      });
                    } else {
                      print("app");
                      loadImagesOnDevices()
                          .then((value) => {
                        // Future.delayed(Duration(milliseconds: 1000)).then((_) {
                        //   print("start image processing");
                        //   createThumbnails();
                        // })

                      });
                    }
                  }
              ),
            );
        } else {
          // Asset asset = imageAssets[index];
          var imageValue = imageUint8Lists[index];

          print(imageValue.runtimeType);

          return Stack(
            children: [
              // AssetThumb(
              //   asset: asset,
              //   width: 300,
              //   height: 300,
              // ),
              Container(
                color: Colors.grey[300],
                child:
                imageValue.runtimeType == String ?
                Image.network(
                  imageValue,
                  fit: BoxFit.cover,
                ) :
                Image.memory(
                  imageValue,
                  fit: BoxFit.cover,
                ),


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
                        if(imageValue.runtimeType != String) {
                          imageAssets.removeAt(index - countUrls()); // imageAssets has a different length
                        }
                      }
                      if(imageValue.runtimeType == String) {
                        widget.post.thumbnailAndImageUrls.remove(imageValue);
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

    List<dynamic> imageUint8ListsTemp = List<dynamic>();
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
        for (var i in imageUint8ListsTemp) {
          imageUint8Lists.add(i);
        }
        // imageUint8Lists = imageUint8ListsTemp;
      }
      _error = error;
    });
  }

  Future<void> loadImagesOnWeb() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']
    );

    if (result != null) {
      // cannot use path, does not support on web https://github.com/miguelpruivo/flutter_file_picker/issues/591
      // List<File> files = result.paths.map((path) => File(path)).toList();
      // File file = File(result.paths.first);

      // print(result.files.first);
      Uint8List imageValue = result.files.first.bytes;
      // File imageFile = File.fromRawPath(imageValue); // uses dart.io, not supported on web

      List<dynamic> imageUint8ListsTemp = result.files.map((file) => file.bytes).toList();

      setState(() {
        // imageFiles = files;
        for (var i in imageUint8ListsTemp) {
          imageUint8Lists.add(i);
        }
        // imageUint8Lists = imageUint8ListsTemp;
      });

    } else {
      // User canceled the picker
    }
  }

  Future<void> savePost(BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // prefs.setString("userName", "");

    var userName = prefs.get("userName");

    print(userName);

    if(userName == "" || userName == null) {
      print("missing user name");
      UniversalFunctions.askForUserMissingInfo(context, true, "Tell us who is posting?");
    } else {

      setState(() {
        print("show progress bar");
        workInProgress = true;
      });

      print("saving post now");
      var currentUserEmail = FirebaseAuth.instance.currentUser.email;


      Post post;

      if(widget.post == null) {
        var currentTimeInUtc = DateTime.now().toUtc();
        var currentTimeInUtcString = currentTimeInUtc.toString().split(".")[0];
        var postDocName = currentTimeInUtcString + " by " + currentUserEmail;
        print(postDocName);
        post = new Post(
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
      } else {

        // if topic changed, we need to delete the old one, because the new post will be save into a another category, the old one won't be overridden.
        if (widget.post.topic != topic) {
          var topicLowerCase = widget.post.topic.toLowerCase();
          FirebaseFirestore.instance.collection('$topicLowerCase posts')
              .doc(widget.post.postDocName)
              .delete();
        }
        post = widget.post;
        post.title=title;
        post.content=content;
        post.topic=topic;
        post.course=course;
        post.imageUint8Lists = imageUint8Lists;
      }

      post.printOut();

      print("start saving post to database");

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
    print("build view");
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Create Post"),),
        actions: [
          Icon(Icons.add, color: UniversalValues.primaryColor,), //  to make the title center
        ],
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

                      TitleWidget(title: topic,),

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



                      // // no need title
                      // Container(
                      //   margin: EdgeInsets.all(20),
                      //   child:
                      //   Column(
                      //     children: [
                      //       title != "" ? Container(margin: EdgeInsets.only(bottom: 5), child: Center(child: Text("Title",),),) : SizedBox(height: 0,),
                      //       TextField(
                      //         controller: titleTextEditingController,
                      //         style: TextStyle(fontSize: 25),
                      //         textAlign: TextAlign.center,
                      //         onChanged: (value){
                      //           setState(() {
                      //             title = value;
                      //           });
                      //         },
                      //         decoration: InputDecoration(
                      //           hintText: "Title",
                      //           alignLabelWithHint: true,
                      //           focusedBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      //           ),
                      //           enabledBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   )
                      // ),

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
                                  // widget.post.printOut();
                                  // print(images);
                                  // print(titleTextEditingController.text);
                                  // print(titleTextEditingController.value);
                                  // if (title != "" && content != "" && topic != "What are Your Posting for?") {
                                  if (content != "" && topic != "What are Your Posting for?") {
                                    if (FirebaseAuth.instance.currentUser != null) {

                                      if(topic == "Academic") {
                                        if (!UniversalValues.courses.contains(course)) {
                                          UniversalFunctions.showToast("Please search/select a course.", UniversalValues.toastMessageTypeWarningColor);
                                        } else {
                                          // save post
                                          savePost(context);
                                        }
                                      } else {
                                        //save post
                                        savePost(context);
                                      }


                                    } else {
                                      // ask for login
                                      print("ask for login");
                                      pushNewScreen(
                                        context,
                                        screen: SignInUpPage(),
                                        withNavBar: false, // OPTIONAL VALUE. True by default.
                                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      );
                                    }

                                  } else {
                                    // if (title == "") {
                                    //   UniversalFunctions.showToast("What's the title?", UniversalValues.toastMessageTypeWarningColor);
                                    // } else

                                      if (content == "") {
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
                    SpinKitFadingCircle(
                      color: Colors.blue,
                      size: 50.0,
                    )
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     CircularProgressIndicator(
                    //       backgroundColor: UniversalValues.primaryColor,
                    //       valueColor: AlwaysStoppedAnimation(Colors.green),
                    //       strokeWidth: 10,
                    //     ),
                    //     SizedBox(height: 15,),
                    //     LinearProgressIndicator(
                    //       backgroundColor: UniversalValues.primaryColor,
                    //       valueColor: AlwaysStoppedAnimation(Colors.green),
                    //       minHeight: 10,
                    //     )
                    //   ],
                    // )


                        :
                    SizedBox(height: 0,),)
                ],
              )
          ),
        )

      )



    );
  }}