import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:qanda/UniversalWidgets.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ShowPostPage extends StatefulWidget{

  ShowPostPage({Key key, this.postDocTypePath, this.postDocName}) : super(key: key);
  var postDocTypePath;
  var postDocName;

  @override
  _ShowPostPageState createState() => _ShowPostPageState();
}

class _ShowPostPageState extends State<ShowPostPage>{

  // int currentImageIndex = 0;
  // double imageSize = 0.3;

  var carouselController = new CarouselController();
  var pageController = new PageController();

  var appBarText = "";


  @override
  void initState() {
    super.initState();
    // this might be changed due to view images outside of show post page
    UniversalValues.currentViewingImageIndex = 0;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        ),
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

                      appBarText = post.title;


                    final List<Widget> imageSliders = imgList.map((item) => Container(
                      child: InkWell(
                        onTap: () {
                          print("tapped an image");
                          print(UniversalValues.currentViewingImageIndex);
                          var pageController = PageController(initialPage: UniversalValues.currentViewingImageIndex);
                          Future<void> future = showCupertinoModalBottomSheet(
                            // expand: false,
                            // bounce: true,
                              useRootNavigator: true,
                              context: context,
                              duration: Duration(milliseconds: 700),
                              builder: (context) =>
                                  LargeImagesPhotoView(pageController: pageController, imageUrls: post.imageUrls)
                          );
                          future.then((void value) {
                            print("bottom sheet closed");
                            print(UniversalValues.currentViewingImageIndex);
                            carouselController.animateToPage(UniversalValues.currentViewingImageIndex);
                          });
                        },
                        child:
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Center(child: Image.network(item, filterQuality: FilterQuality.low, fit: BoxFit.cover, width: MediaQuery.of(context).size.width * 0.9),),
                        )

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
                                       Center(child: Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch)) + " by " + post.author),),
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
                        //   options: CarouselOptions              //     height: MediaQuery.of(context).size.height,
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

                        post.imageUrls.length == 0 ?
                            SizedBox(height: 0,) : 
                        Column(
                            children: [
                              CarouselSlider(
                                items: imageSliders,
                                carouselController: carouselController,
                                options: CarouselOptions(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2,
                                    onPageChanged: (index, reason) {
                                      // print(index);
                                      setState(() {
                                        UniversalValues.currentViewingImageIndex = index;
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
                                      color: UniversalValues.currentViewingImageIndex == index
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

                        // FlatButton(
                        //   color: Colors.blueAccent,
                        //   textColor: Colors.white,
                        //   onPressed: () {
                        //     print(content);
                        //     post.printOut();
                        //   },
                        //   child: Center(child: Text("something here")),
                        // ),

                        SizedBox(height: 20,),
                      ],
                    );

                    postWidget.add(contentToDisplay);

                  }
                  return

                    ListView(
                      children: postWidget
                  );
                },
              ),
          )
      )
    );
  }
}