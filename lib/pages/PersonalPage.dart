

import 'package:awesome_dialog/awesome_dialog.dart';
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
  PersonalPage({Key key,this.userEmail}) : super(key: key);
  final userEmail;

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>{

  var signInOurButtonIcon = Icon(Icons.person);
  // UserInformation userInformation;
  UserInformation userInformation = new UserInformation();

  var email = "signed out";

  @override
  void initState() {
    super.initState();
    email = widget.userEmail;
    // if passed in email is "" they we listen to auth change
    // otherwise it's just another user viewing the profile, no need to listen

    if(email == "signed out") {
      FirebaseAuth.instance
          .authStateChanges()
          .listen((User user) {
        if (user == null) {
          print('User is currently signed out!');
          setState(() {
            signInOurButtonIcon = Icon(Icons.login);
            // if(userInformation != null) {
            //   userInformation.clearLocal();
            //   userInformation = null;
            // }
            email = "signed out";
            // userInformation.clearLocal();
            userInformation.name = "";
            userInformation.email = "";
            userInformation.major = "";
            userInformation.profileImageUrl = "";
          });
        } else {
          print('User is signed in!');
          setState(() {
            signInOurButtonIcon = Icon(Icons.logout);
            // userInformation = new UserInformation(email: user.email);
            email = user.email;
          });
          // userInformation.get();
        }
      });
    }



  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(""),),
          leading: widget.userEmail == "signed out" ? SizedBox(width: 0,) : BackButton(),
          actions: [
            widget.userEmail == "signed out" ?
            FirebaseAuth.instance.currentUser == null ?
            SizedBox(width: 0,) :
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
            ) :
            SizedBox(width: 0,),

            widget.userEmail == "signed out" ?
            IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  AwesomeDialog(
                    width: 400,
                    context: context,
                    useRootNavigator: true,
                    dialogType: DialogType.NO_HEADER,
                    customHeader: Image.asset("assets/images/logo.png"),
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'About BYU-H App',
                    // desc: "Programming by Litian Zhang under the supervision of Dr. Geoffrey Draper at Brigham Young University--Hawaii.",
                    desc: "This app serves as a campus communication platform.",
                    btnOkText: "Dismiss",
                    btnOkColor: Colors.blueAccent,
                    btnOkOnPress: () {},
                  )..show();
                }
            ) :
            SizedBox(width: 0,),
          ],
        ),
        body: Center(
            child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(email)
                      .snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.hasData && snapshot.data.data() != null) {
                     // if(userInformation != null) {
                     //   userInformation.profileImageUrl = snapshot.data.data()["profile image url"];
                     //   userInformation.name = snapshot.data.data()["name"];
                     // }

                      userInformation.profileImageUrl = snapshot.data.data()["profile image url"];
                      userInformation.name = snapshot.data.data()["name"];
                      userInformation.email = snapshot.data.data()["email"];
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

                                  if(widget.userEmail == "signed out") {
                                    if(FirebaseAuth.instance.currentUser != null) {
                                      showCupertinoModalBottomSheet(
                                        enableDrag: true,
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        context: context,
                                        duration: Duration(milliseconds: 700),
                                        builder: (context) => UserInfoFormWidget(userName: userInformation.name, messageText: "Update Profile", profileUrl: userInformation.profileImageUrl,),
                                      );
                                    } else {
                                      UniversalFunctions.askForSignIn(context);
                                    }
                                  }


                                },
                                child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image:
                                            // userInformation == null
                                            //     ?
                                            // AssetImage("assets/images/no_photo.png")
                                            //     :
                                            // userInformation.profileImageUrl == ""
                                            email == "signed out"
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
                                  if(widget.userEmail == "signed out") {
                                    if(FirebaseAuth.instance.currentUser != null) {
                                      showCupertinoModalBottomSheet(
                                        enableDrag: true,
                                        isDismissible: true,
                                        useRootNavigator: true,
                                        context: context,
                                        duration: Duration(milliseconds: 700),
                                        builder: (context) => UserInfoFormWidget(userName: userInformation.name, messageText: "Update Profile", profileUrl: userInformation.profileImageUrl,),
                                      );
                                    } else {
                                      UniversalFunctions.askForSignIn(context);
                                    }
                                  }
                                },
                                child: Container(
                                    child: Text(
                                      // userInformation == null ? "   "
                                      email == "signed out" ? "    "
                                          : userInformation.name,
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
                                              color: widget.userEmail == "signed out" ? FirebaseAuth.instance.currentUser == null ? Colors.grey : Colors.blue : Colors.blueAccent,
                                              textColor: Colors.white,
                                              disabledColor: Colors.grey,
                                              disabledTextColor: Colors.black,
                                              padding: EdgeInsets.all(8.0),
                                              splashColor: widget.userEmail == "signed out" ? FirebaseAuth.instance.currentUser == null ? Colors.black54 : Colors.blueAccent : Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              ),
                                              onPressed: () {

                                                if(widget.userEmail == "signed out") {
                                                  if(FirebaseAuth.instance.currentUser != null) {
                                                    pushNewScreen(
                                                      context,
                                                      screen: PostsPage(postType: "campus life posts", searchPerson: userInformation.email,),
                                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                    );
                                                  } else {
                                                    UniversalFunctions.askForSignIn(context);
                                                  }
                                                } else {
                                                  pushNewScreen(
                                                    context,
                                                    screen: PostsPage(postType: "campus life posts", searchPerson: userInformation.email,),
                                                    withNavBar: false, // OPTIONAL VALUE. True by default.
                                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                  );
                                                }


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
                                              color: widget.userEmail == "signed out" ? FirebaseAuth.instance.currentUser == null ? Colors.grey : Colors.blue : Colors.blueAccent,
                                              textColor: Colors.white,
                                              disabledColor: Colors.grey,
                                              disabledTextColor: Colors.black,
                                              padding: EdgeInsets.all(8.0),
                                              splashColor: widget.userEmail == "signed out" ? FirebaseAuth.instance.currentUser == null ? Colors.black54 : Colors.blueAccent : Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                              ),
                                              onPressed: () {

                                                if(widget.userEmail == "signed out") {
                                                  if(FirebaseAuth.instance.currentUser != null) {
                                                    pushNewScreen(
                                                      context,
                                                      screen: PostsPage(postType: "academic posts", searchPerson: userInformation.email,),
                                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                    );
                                                  } else {
                                                    UniversalFunctions.askForSignIn(context);
                                                  }
                                                } else {
                                                  pushNewScreen(
                                                    context,
                                                    screen: PostsPage(postType: "academic posts", searchPerson: userInformation.email,),
                                                    withNavBar: false, // OPTIONAL VALUE. True by default.
                                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                                  );
                                                }



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
                    // else {
                    //   return Center(
                    //     child: NiceButton(
                    //       // width: 250,
                    //       radius: 40,
                    //       padding: const EdgeInsets.all(15),
                    //       icon: Icons.flight_takeoff_rounded,
                    //       gradientColors: [Color(0xff5b86e5), Color(0xff36d1dc)],
                    //       text: "Sign In",
                    //       onPressed: () {
                    //         print("go to sign in page");
                    //         pushNewScreen(
                    //           context,
                    //           screen: SignInUpPage(),
                    //           withNavBar: false, // OPTIONAL VALUE. True by default.
                    //           pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    //         );
                    //       },
                    //     ),
                    //
                    //   );
                    // }
                  }
              ),
            )
        )
    );
  }
}
