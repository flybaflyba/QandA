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

  int _current = 0;

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

                    var imgList = post.imageUrls;

                    final List<Widget> imageSliders = imgList.map((item) => Container(
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            child: Stack(
                              children: <Widget>[
                                Image.network(item, fit: BoxFit.cover, width: 1000.0),
                                // Positioned(
                                //   bottom: 0.0,
                                //   left: 0.0,
                                //   right: 0.0,
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       gradient: LinearGradient(
                                //         colors: [
                                //           Color.fromARGB(200, 0, 0, 0),
                                //           Color.fromARGB(0, 0, 0, 0)
                                //         ],
                                //         begin: Alignment.bottomCenter,
                                //         end: Alignment.topCenter,
                                //       ),
                                //     ),
                                //     padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                //     child: Text(
                                //       '${imgList.indexOf(item)}',
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: 20.0,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            )
                        ),
                      ),
                    )).toList();

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

                        Column(
                            children: [
                              CarouselSlider(
                                items: imageSliders,
                                options: CarouselOptions(
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2.0,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _current = index;
                                      });
                                    }
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: imgList.map((url) {
                                  int index = imgList.indexOf(url);
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _current == index
                                          ? Color.fromRGBO(0, 0, 0, 0.9)
                                          : Color.fromRGBO(0, 0, 0, 0.4),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ]
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