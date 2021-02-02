
import 'package:flutter/material.dart';


class PersonalPage extends StatefulWidget{

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
    child: ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Your Home Page"),
        ),
      ],
    )))
    );
  }
}
