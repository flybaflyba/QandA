
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/SignInUpPage.dart';
import 'package:qanda/UniversalValues.dart';


class PersonalPage extends StatefulWidget{

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Home"),),
          leading: Icon(Icons.logout, color: UniversalValues.primaryColor,), //  to make the title center
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  print("sign out button pressed");
                  FirebaseAuth.instance.signOut();
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SignInUpPage(),));
                  // pushNewScreen(
                  //   context,
                  //   screen: SignInUpPage(),
                  //   withNavBar: false, // OPTIONAL VALUE. True by default.
                  //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  // );
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
