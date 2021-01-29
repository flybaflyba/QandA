import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalFunctions.dart';

class ShowPostPage extends StatefulWidget{

  @override
  _ShowPostPageState createState() => _ShowPostPageState();
}

class _ShowPostPageState extends State<ShowPostPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('academic posts')
                    .doc("2021-01-29 04:06:20 by 1@1.com")
                    .snapshots(),
                builder: (context, snapshot){
                  List<Widget> postWidget = [];

                  if(snapshot.hasData){
                    final content = snapshot.data;
                    Post post = new Post();
                    post.setPostWithDocumentSnapshot(snapshot.data);
                    final contentToDisplay =
                    Column(
                      children: [
                        FlatButton(
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          onPressed: () {
                            print(content);
                            post.printOut();

                          },
                          child: Center(child: Text("something here")),
                        ),
                        SizedBox(height: 10,),
                      ],
                    );

                    postWidget.add(contentToDisplay);

                  }
                  return Column(
                      children: postWidget
                  );
                },
              ),
          )
      )
    );
  }
}