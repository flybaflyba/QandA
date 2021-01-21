

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/BlankPage.dart';

BuildContext selectedTabScreenContext;

class MenuPage extends StatefulWidget{

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>{

  PersistentTabController controller;
  bool hideNavBar;

  List<Widget> buildScreens = [
    BlankPage(),
    BlankPage(),
    BlankPage(),
  ];

  List<PersistentBottomNavBarItem> navBarsItems =
    [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("World"),
        activeColor: Color.fromRGBO(158, 27, 52, 100), // TODO externalize color Crimson
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.create),
        title: ("Create"),
        activeColor: Color.fromRGBO(158, 27, 52, 100), // TODO externalize color Crimson
        inactiveColor: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person),
        title: ("Home"),
        activeColor: Color.fromRGBO(158, 27, 52, 100), // TODO externalize color Crimson
        inactiveColor: CupertinoColors.systemGrey,
      ),
    ];


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(158, 27, 52, 100), // TODO externalize color Crimson
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
          duration: Duration(milliseconds: 400),
        ),
        navBarStyle: NavBarStyle.style3, // Choose the nav bar style with this property
      )
    );
  }

}