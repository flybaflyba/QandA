
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/Comment.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/SignInUpPage.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:qanda/UserInformation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UniversalFunctions{

  static void showToast(String msg, Color toastMessageType) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: toastMessageType,
        webBgColor: toastMessageType == UniversalValues.toastMessageTypeWarningColor ? "linear-gradient(to right, #cc00ff, #ff0000)" : "	linear-gradient(to right, #00b09b, #96c93d)",
        webPosition: "center",
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  // for now, we only checks for user names
  static Future<void> askForUserMissingInfo(BuildContext context, bool dismissible, String messageText) async {

    // check if we have user name locally if not get from database
    UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
    userInformation.get()
        .then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userName = prefs.getString("userName");
      if(userName == null || userName == "") {
        print("missing user name from database");
        // ask user for info
        var boxConstraints = BoxConstraints(minWidth: 100, maxWidth: 250);
        var boxColor = Colors.white;
        showCupertinoModalBottomSheet(
          // expand: false,
          // bounce: true,
            enableDrag: dismissible,
            isDismissible: dismissible,
            useRootNavigator: true,
            context: context,
            duration: Duration(milliseconds: 700),
            builder: (context) =>
                Scaffold(
                    backgroundColor: Colors.blue,
                    body: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(minWidth: 150, maxWidth: 350),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            // color: Colors.redAccent,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 20,),
                                ListTile(
                                  title: Text(
                                    messageText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // IconButton(icon: Icon(Icons.person), onPressed: null),
                                      Container(
                                        color: boxColor,
                                        constraints: boxConstraints,
                                        margin: EdgeInsets.only(left: 10),
                                        child: TextField(
                                          onChanged: (value){
                                            userName = value;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "What do you want to be called?",
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      // color: boxColor,
                                      // constraints: boxConstraints,
                                      height: 60,
                                      child: NiceButton(
                                        width: 250,
                                        radius: 40,
                                        padding: const EdgeInsets.all(15),
                                        // icon: Icons.account_box,
                                        gradientColors: [Color(0xff5b86e5), Color(0xff36d1dc)],
                                        text: "Ok",
                                        onPressed: () async {

                                          if (userName == "") {
                                            print("user name not set");
                                            UniversalFunctions.showToast("Username is not set", UniversalValues.toastMessageTypeWarningColor);
                                          } else {
                                            UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
                                            userInformation.name = userName;
                                            userInformation.update();
                                            prefs.setString("userName", userName);
                                            UniversalFunctions.showToast("Username updated", UniversalValues.toastMessageTypeGoodColor);
                                          }

                                          Navigator.of(context, rootNavigator: true).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    )
                )
        );
      } else {
        print("user name is not saved locally but get from database");
      }
    });

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var userName = prefs.getString("userName");
    // print(userName);
    // print("user name in local storage is: " + userName);
    // if(userName == null || userName == "") {
    //   print("no user name set");
    //
    // }
  }

  static void showCommentInput(BuildContext context, Post post, Comment comment, String to, String toEmail) {

    var currentComment = "";
    var focused = false;
    showCupertinoModalBottomSheet(
        expand: false,
        // bounce: true,
        useRootNavigator: true,
        context: context,
        duration: Duration(milliseconds: 700),
        builder: (context) {
          var focusNode = new FocusNode();
          if(!focused) {
            print("let's focus");
            focused = true;
            Future.delayed(Duration(milliseconds: 10)).then((_) async {
              FocusScope.of(context).requestFocus(focusNode);
            });
          }
          return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Wrap(
                children: [
                  Material(
                      child: Column(
                        children: [
                          // currentComment == "" ?
                          // SizedBox(height: 10,)
                          // :
                          Container(
                            // color: Colors.redAccent,
                              child: IconButton(
                                icon: Icon(Icons.send_rounded),
                                onPressed: () async {
                                  print(currentComment);
                                  // save comment
                                  if(currentComment == "") {
                                    UniversalFunctions.showToast("Please enter your comments", UniversalValues.toastMessageTypeWarningColor);
                                  } else {
                                    // check if user is logged in, if not, ask to login
                                    if (FirebaseAuth.instance.currentUser != null) {
                                      // save comment
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      var userName = prefs.get("userName");
                                      print(userName);
                                      // prefs.setString("userName", "");
                                      if(userName == "" || userName == null) {
                                        print("missing user name");
                                        UniversalFunctions.askForUserMissingInfo(context, true, "Tell us who is commenting");
                                      } else {
                                        var currentTimeInUtc = DateTime.now().toUtc();
                                        Comment commentTemp = new Comment(content: currentComment, time: currentTimeInUtc, by: userName, byEmail: FirebaseAuth.instance.currentUser.email);

                                        // check if we are creating a new comment, or we are replying a comment.
                                        if(comment == null) {
                                          // comment we just created
                                          commentTemp.create(post);
                                        } else {
                                          // update, add a reply to existing comment
                                          commentTemp.to = to;
                                          commentTemp.toEmail = toEmail;
                                          comment.replies.add(commentTemp.toMap());
                                          comment.update(post);

                                        }
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      // check if user is logged in, if not, ask to login
                                      print("ask for login");
                                      // hide keyboard
                                      // FocusScope.of(context).requestFocus(FocusNode()); // cannot user, for some reason there is a red error after i enter text, does not cause any crashing but i think that is why i cannot use this to close keyborad
                                      SystemChannels.textInput.invokeMethod('TextInput.hide');

                                      pushNewScreen(
                                        context,
                                        screen: SignInUpPage(),
                                        withNavBar: false, // OPTIONAL VALUE. True by default.
                                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      );
                                      }
                                  }
                                },
                              )
                          ),

                          // indicating who we are replying to if we are replying
                          comment == null
                              ?
                          SizedBox(height: 0,)
                              :
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Replying "),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(comment.by, style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                              ],
                            )
                          ),

                          Container(
                            // color: Colors.blueAccent,
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                            child: TextField(
                              minLines: 1,
                              maxLines: 10,
                              focusNode: focusNode,
                              // style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.left,
                              onChanged: (value){
                                // print(value);
                                currentComment = value;
                              },
                              decoration: InputDecoration(
                                hintText: "Your comments",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )



                    // Row(
                    //   children: [
                    //
                    //

                    //   ],
                    // ),
                  )
                ],
              )
          );
        }
    );


  }

  static Future<List<Widget>> getTopImages(BuildContext context) async {
    List<Widget> topImageWidgets = List<Widget>();
    List<String> topImageUrls = List<String>();
    firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref("top images").listAll();
    for(firebase_storage.Reference ref in result.items){
      var url = await ref.getDownloadURL();
      print(url);
      topImageUrls.add(url);
      topImageWidgets.add(
          Container(
            child: InkWell(
                onTap: () {
                  print("tapped top image " + url);
                  // make sure top image urls are all collected
                  UniversalValues.currentViewingImageIndex = topImageUrls.indexOf(url);
                  if(topImageWidgets.length == result.items.length) {
                    UniversalValues.currentViewingImageIndex = topImageUrls.indexOf(url); // we need this so that indicator in large view is at the right position
                    var pageController = PageController(initialPage: topImageUrls.indexOf(url));
                    Future<void> future = showCupertinoModalBottomSheet(
                      // expand: false,
                      // bounce: true,
                        useRootNavigator: true,
                        context: context,
                        duration: Duration(milliseconds: 700),
                        builder: (context) =>
                            LargeImagesPhotoView(pageController: pageController, imageUrls: topImageUrls)
                    );
                    future.then((void value) {
                      print("bottom sheet closed");
                      UniversalValues.currentViewingImageIndex = 0; // try not to change it because we are not in show post page
                      print(UniversalValues.currentViewingImageIndex);
                    });
                  }
                },
                child:
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Center(
                      child: Image.network(
                        url,
                        filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                              child: Container(
                                color: Colors.grey[300],
                                child: SpinKitDoubleBounce(
                                  color: Colors.blue,
                                  size: 50.0,
                                ),
                              )
                            // CircularProgressIndicator(
                            //   value: loadingProgress.expectedTotalBytes != null ?
                            //   loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                            //       : null,
                            // ),
                          );
                        },
                      )
                  ),
                )
            ),
          )
      );
    }
    print("end of get top images");
    return topImageWidgets;
  }

}