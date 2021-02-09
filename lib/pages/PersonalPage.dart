
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
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
        });
      } else {
        print('User is signed in!');
        setState(() {
          signInOurButtonIcon = Icon(Icons.logout);
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
                    UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
                    userInformation.clearLocal();
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
        Padding(
          padding: EdgeInsets.all(10),
          child: Center(child: Text("Your Home Page"),),
        ),
      ],
    )))
    );
  }
}
