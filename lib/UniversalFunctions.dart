
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString("userName");
    print(userName);
    if(userName == null || userName == "") {
      UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
      userInformation.get()
          .then((value) {
        userName = prefs.getString("userName");
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

                                            userInformation.name = userName;
                                            userInformation.update();
                                            prefs.setString("userName", userName);

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
      });
    }
  }

}