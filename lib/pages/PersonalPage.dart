
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/customWidgets/TitleWidget.dart';
import 'package:qanda/customWidgets/UserInfoFormWidget.dart';
import 'package:qanda/models/UserInformation.dart';
import 'package:qanda/pages/SignInUpPage.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PersonalPage extends StatefulWidget{

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>{

  var signInOurButtonIcon = Icon(Icons.person);
  UserInformation userInformation;


  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          signInOurButtonIcon = Icon(Icons.login);
          userInformation.clearLocal();
          userInformation = null;
        });
      } else {
        print('User is signed in!');
        setState(() {
          signInOurButtonIcon = Icon(Icons.logout);
          userInformation = new UserInformation(email: user.email);
        });
        userInformation.get().whenComplete(() {
          setState(() {
            userInformation.profileImageUrl = userInformation.profileImageUrl;
          });
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Home"),),
          leading: Icon(Icons.logout, color: UniversalValues.primaryColor,), //  to make the title center
          actions: [
            IconButton(
                icon: signInOurButtonIcon,
                onPressed: () async {
                  if(FirebaseAuth.instance.currentUser == null) {
                    pushNewScreen(
                      context,
                      screen: SignInUpPage(),
                      withNavBar: false, // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  } else {
                    print("sign out button pressed");
                    FirebaseAuth.instance.signOut();
                    UniversalFunctions.showToast("Your are logged out", UniversalValues.toastMessageTypeGoodColor);
                  }

                }
            ),
          ],
        ),
      body: Center(
        child: Container(
        constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
    child: ListView(
      children: [

        // Center(
        //   child: FlatButton(
        //     onPressed: () {
        //       userInformation.printOut();
        //       print(userInformation.name);
        //       print(userInformation.email);
        //       print(userInformation.profileImageUrl);
        //     },
        //     child: Text("Aloha"),
        //   ),
        // ),

        Padding(
          padding: EdgeInsets.only(top: 30),
          child: Center(
            child: InkWell(
                onTap: () {

                  showCupertinoModalBottomSheet(

                    enableDrag: true,
                    isDismissible: true,
                    useRootNavigator: true,
                    context: context,
                    duration: Duration(milliseconds: 700),
                    builder: (context) => UserInfoFormWidget(userName: " ", messageText: "UpdateProfile",),
                  );


                },
                child: Container(
                    width: 150,
                    height: 150,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image:
                            userInformation == null
                                ?
                            AssetImage("assets/images/no_photo.png")
                                :
                            NetworkImage(userInformation.profileImageUrl)
                        )
                    )
                )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Center(
            child: InkWell(
                onTap: () {

                },
                child: Container(
                  child: Text(
                    userInformation == null ? "   " : userInformation.name,
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  )
                )
            ),
          ),
        ),
      ],
    )))
    );
  }
}
