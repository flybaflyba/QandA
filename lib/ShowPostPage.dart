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

  int currentImageIndex = 0;
  double imageSize = 0.3;

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
                    // print(snapshot.data.data());
                    Post post = new Post();
                    post.setPostWithDocumentSnapshot(snapshot.data);

                    var imgList = post.imageUrls;

                    final List<Widget> imageSliders = imgList.map((item) => Container(
                      height:  MediaQuery.of(context).size.height,
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: InkWell(
                          onTap: () {
                            print("tapped an image");
                            // setState(() {
                            //   if (imageSize == 0.3) {
                            //     imageSize = 0.6;
                            //   } else {
                            //     imageSize = 0.3;
                            //   }
                            // });
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                children: <Widget>[
                                  // if the image quality is too high, might not load because of time out error, we can also set scale to 0.1 for example
                                  Center(child: Image.network(item, filterQuality: FilterQuality.low, fit: BoxFit.cover, width: MediaQuery.of(context).size.width * 0.9),)
                                  // indicator on image
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
                        ),
                    )).toList();

                    final contentToDisplay =
                    Column(
                      children: [

                       Padding(
                           padding: EdgeInsets.only(bottom: 10),
                           child:  Container(
                             color: Colors.grey[300],
                             child: Column(
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
                               ],
                             ),
                           ),
                       ),


                        // Center(child: Text(DateFormat.yMEd().add_jms().format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),
                        // Center(child: Text(timeago.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),


                        // CarouselSlider(
                        //   options: CarouselOptions(
                        //     height: MediaQuery.of(context).size.height,
                        //     viewportFraction: 1.0,
                        //     enlargeCenterPage: false,
                        //     // autoPlay: false,
                        //   ),
                        //   items: imgList.map((item) => Container(
                        //     child: Center(
                        //         child: Image.network(item, fit: BoxFit.cover, )
                        //     ),
                        //   )).toList(),
                        // ),


                        Column(
                            children: [
                              CarouselSlider(
                                items: imageSliders,
                                options: CarouselOptions(
                                    height: MediaQuery.of(context).size.height * imageSize,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentImageIndex = index;
                                      });
                                    }
                                ),
                              ),
                              // indicator
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
                                      color: currentImageIndex == index
                                          ? Color.fromRGBO(0, 0, 0, 0.9)
                                          : Color.fromRGBO(0, 0, 0, 0.4),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ]
                        ),
                        
                        // SizedBox(height: 20, child: Container(color: Colors.white,),),

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