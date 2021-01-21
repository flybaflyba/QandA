
import 'package:flutter/material.dart';

class BlankPage extends StatefulWidget{

  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Blank Page"),),
    );
  }}