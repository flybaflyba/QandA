
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nice_button/nice_button.dart';
import 'package:qanda/models/UserInformation.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoFormWidget extends StatefulWidget{

  UserInfoFormWidget({Key key, this.userName, this.messageText}) : super(key: key);
  var userName;
  var messageText;

  @override
  _UserInfoFormWidgetState createState() => _UserInfoFormWidgetState();
}

class _UserInfoFormWidgetState extends State<UserInfoFormWidget>{

  var boxConstraints = BoxConstraints(minWidth: 100, maxWidth: 250);
  var boxColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        widget.messageText,
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
                                widget.userName = value;
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

                              if (widget.userName == "") {
                                print("user name not set");
                                UniversalFunctions.showToast("Username is not set", UniversalValues.toastMessageTypeWarningColor);
                              } else {
                                UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
                                userInformation.name = widget.userName;
                                userInformation.update();
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("userName", widget.userName);
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
    );
  }
}