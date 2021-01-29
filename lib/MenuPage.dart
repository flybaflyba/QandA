

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/BlankPages.dart';
import 'package:qanda/CreatePostPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:qanda/UserInformation.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext selectedTabScreenContext;

class MenuPage extends StatefulWidget{

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>{

  PersistentTabController controller;
  bool hideNavBar;

  List<Widget> buildScreens = [
    BlankPage1(),
    CreatePostPage(),
    BlankPage2(),
  ];

  List<PersistentBottomNavBarItem> navBarsItems =
    [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("World"),
        activeColor: UniversalValues.primaryColor, // Color.fromRGBO(158, 27, 52, 100),
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.create),
        title: ("Create"),
        activeColor: UniversalValues.primaryColor,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person),
        title: ("Home"),
        activeColor: UniversalValues.primaryColor,
        inactiveColor: CupertinoColors.systemGrey,
      ),
    ];


  @override
  void initState() {
    super.initState();

    // new Timer.periodic(Duration(seconds:1), (Timer t) async {
    //   print("Timer in MenuPage running");
    //
    // });

    UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
    userInformation.get()
        .then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var userName = prefs.getString("userName");
          if(userName == null || userName == "") {
            print("missing user name from database");
          }
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: UniversalValues.primaryColor,
        title: Text("Q&A"),
      ),
      body: PersistentTabView(
        context,
        controller: controller,
        screens: buildScreens,
        items: navBarsItems,
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        hideNavigationBarWhenKeyboardShows: true,
        margin: EdgeInsets.all(0.0),
        popActionScreens: PopActionScreensType.once,
        bottomScreenMargin: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        onWillPop: () async {

          return true;
        },
        selectedTabScreenContext: (context) {
          selectedTabScreenContext = context;
        },
        hideNavigationBar: hideNavBar,
        decoration: NavBarDecoration(
            colorBehindNavBar: Colors.indigo,
            borderRadius: BorderRadius.circular(0.0)),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style3, // Choose the nav bar style with this property
      )
    );
  }

}