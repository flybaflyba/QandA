
import 'package:flutter/material.dart';
import 'file:///C:/Projects/QandA/lib/universals/UniversalFunctions.dart';

class BlankPage1 extends StatefulWidget{

  @override
  _BlankPage1State createState() => _BlankPage1State();
}

class _BlankPage1State extends State<BlankPage1>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Blank Page"),),
    );
  }
}

class BlankPage2 extends StatefulWidget{

  @override
  _BlankPage2State createState() => _BlankPage2State();
}

class _BlankPage2State extends State<BlankPage2>{

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000)).then((_) async {
      UniversalFunctions.askForUserMissingInfo(context, true, "Let's get to know you");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Blank Page 2"),),
    );
  }
}