
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/Comment.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:qanda/UserInformation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // TODO is it necessary to check if we have it locally?
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString("userName");
    print(userName);
    if(userName == null || userName == "") {
      print("no user name set");
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
    }
  }


  static void showCommentInput(BuildContext context, Post post, Comment comment) {

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
                                        commentTemp.to = post.author;
                                        commentTemp.toEmail = post.authorEmail;
                                        comment.replies.add(commentTemp.toMap());
                                        comment.update(post);

                                      }


                                      Navigator.pop(context);
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

}