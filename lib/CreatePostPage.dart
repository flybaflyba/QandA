
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalValues.dart';

class CreatePostPage extends StatefulWidget{

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>{

  TextEditingController titleTextEditingController = new TextEditingController();

  var title = "";
  var content = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: Column(
                children: [
                  SizedBox(height: 20,),

                  Container(
                    margin: EdgeInsets.all(20),
                    child:
                    TextField(
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                      onChanged: (value){
                         title = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Title",
                        alignLabelWithHint: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(20),
                    child:
                    TextField(
                      minLines: 1,
                      maxLines: 100,
                      textAlign: TextAlign.left,
                      onChanged: (value){
                        content = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Content",
                        alignLabelWithHint: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 60,
                        child: RaisedButton(
                          onPressed: () {
                            Post post = new Post(
                                title: title,
                                content: content,
                                author: FirebaseAuth.instance.currentUser.email,
                                createdTime: DateTime.now().toString()
                            );
                            post.printOut();
                            post.create();
                          },
                          color: UniversalValues.buttonColor,
                          child: Text(
                            'Create',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

              ),
            ),
          )
      ),
    );
  }}