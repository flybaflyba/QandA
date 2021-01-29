import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalWidgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowPostPage extends StatefulWidget{

  ShowPostPage({Key key, this.postDocTypePath, this.postDocName}) : super(key: key);
  var postDocTypePath;
  var postDocName;

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
                    .collection(widget.postDocTypePath)
                    .doc(widget.postDocName)
                    .snapshots(),
                builder: (context, snapshot){
                  List<Widget> postWidget = [];

                  if(snapshot.hasData){
                    final content = snapshot.data;
                    print(snapshot.data.data());
                    Post post = new Post();
                    post.setPostWithDocumentSnapshot(snapshot.data);
                    final contentToDisplay =
                    Column(
                      children: [

                        UniversalWidgets.titleWidget(post.title),

                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(child: Text(post.topic + " " + post.course),),
                              Center(child: Text(timeago.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch)) + " by " + post.author),),
                            ],
                          ),
                        ),

                        // Center(child: Text(DateFormat.yMEd().add_jms().format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),
                        // Center(child: Text(timeago.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),

                        CarouselSlider(
                          options: CarouselOptions(height: 300.0),
                          items: post.imageUrls.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300]
                                  ),
                                  child: Image.network(i),
                                );
                              },
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 20, child: Container(color: Colors.white,),),

                        Container(
                          color: Colors.grey[300],
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, right: 50, bottom: 20, top: 20),
                            child:
                            Container(
                              child: Center(
                                child: Text(
                                  post.content,
                                  maxLines: 100,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        FlatButton(
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          onPressed: () {
                            print(content);
                            post.printOut();
                          },
                          child: Center(child: Text("something here")),
                        ),

                        SizedBox(height: 20,),
                      ],
                    );

                    postWidget.add(contentToDisplay);

                  }
                  return ListView(
                      children: postWidget
                  );
                },
              ),
          )
      )
    );
  }
}