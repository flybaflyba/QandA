
import 'package:flutter/material.dart';
import 'package:qanda/pages/MenuPage.dart';
import 'package:qanda/pages/OnBoardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget{

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>{

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1)).then((_) async {
      print("hi");
      await SharedPreferences.getInstance().then((value) {
        var returnUser = value.getBool("returnUser");
        print(returnUser);
        if (returnUser == null) {
          value.setBool("returnUser", true);
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OnBoardingPage()),
          );
        } else {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MenuPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(""),),
    );
  }
}