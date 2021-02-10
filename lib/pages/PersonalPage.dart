
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/customWidgets/PostListWidget.dart';
import 'package:qanda/customWidgets/TitleWidget.dart';
import 'package:qanda/customWidgets/UserInfoFormWidget.dart';
import 'package:qanda/models/UserInformation.dart';
import 'package:qanda/pages/PostsPage.dart';
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
          if(userInformation != null) {
            userInformation.clearLocal();
            userInformation = null;
          }
        });
      } else {
        print('User is signed in!');
        setState(() {
          signInOurButtonIcon = Icon(Icons.logout);
          userInformation = new UserInformation(email: user.email);
        });
        userInformation.get();
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
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userInformation == null ? "ss" : userInformation.email)
                      .snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.hasData && snapshot.data.data() != null) {
                     if(userInformation != null) {
                       userInformation.profileImageUrl = snapshot.data.data()["profile image url"];
                       userInformation.name = snapshot.data.data()["name"];
                     }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                      builder: (context) => UserInfoFormWidget(userName: userInformation.name, messageText: "Update Profile", profileUrl: userInformation.profileImageUrl,),
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
                                              userInformation.profileImageUrl == ""
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
                                    showCupertinoModalBottomSheet(
                                      enableDrag: true,
                                      isDismissible: true,
                                      useRootNavigator: true,
                                      context: context,
                                      duration: Duration(milliseconds: 700),
                                      builder: (context) => UserInfoFormWidget(userName: userInformation.name, messageText: "Update Profile", profileUrl: userInformation.profileImageUrl,),
                                    );
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
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Container(
                                        child: FlatButton(
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          disabledColor: Colors.grey,
                                          disabledTextColor: Colors.black,
                                          padding: EdgeInsets.all(8.0),
                                          splashColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                          ),
                                          onPressed: () {
                                            pushNewScreen(
                                              context,
                                              screen: PostsPage(postType: "campus life posts", searchPerson: userInformation.email,),
                                              withNavBar: false, // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                            );

                                          },
                                          child: Column(
                                            children: [
                                              Icon(Icons.nightlife),
                                            ],
                                          ),
                                        )
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Container(
                                        child: FlatButton(
                                          color: Colors.blue,
                                          textColor: Colors.white,
                                          disabledColor: Colors.grey,
                                          disabledTextColor: Colors.black,
                                          padding: EdgeInsets.all(8.0),
                                          splashColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          ),
                                          onPressed: () {
                                            pushNewScreen(
                                              context,
                                              screen: PostsPage(postType: "academic posts", searchPerson: userInformation.email,),
                                              withNavBar: false, // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                            );

                                          },
                                          child: Column(
                                            children: [
                                              Icon(Icons.school),
                                            ],
                                          ),
                                        )


                                      )
                                  ),
                                ],
                              )
                            )
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: NiceButton(
                          // width: 250,
                          radius: 40,
                          padding: const EdgeInsets.all(15),
                          icon: Icons.flight_takeoff_rounded,
                          gradientColors: [Color(0xff5b86e5), Color(0xff36d1dc)],
                          text: "Sign In",
                          onPressed: () {
                            print("go to sign in page");
                            pushNewScreen(
                              context,
                              screen: SignInUpPage(),
                              withNavBar: false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                        ),

                      );
                    }
                  }
              ),
            )
        )
    );
  }
}
