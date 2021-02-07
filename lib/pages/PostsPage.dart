

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qanda/customWidgets/PostListWidget.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostsPage extends StatefulWidget{
  PostsPage({Key key, @required this.postType}) : super(key: key);

  final postType;

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>{


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: AppBar(
          title: Center(child: Text(widget.postType == "academic posts" ? "Academic" : "Campus Life"),),
        ),
        body: Center(
            child: Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
                child:
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.postType)
                        .snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        var docs = snapshot.data.docs.reversed;
                        print(docs.length);
                        return PostListWidget(postType: widget.postType, allPostsStream: docs,);
                      } else {
                        return SpinKitRipple(
                          color: Colors.blue,
                          size: 50.0,
                        );
                      }
                    }
                )
                // if we put PostList in this ListView, lazy load won't load more
                // ListView(
                //   // physics: NeverScrollableScrollPhysics(),
                //   children: [
                //     // main page top images
                //     Padding(
                //       padding: EdgeInsets.all(20),
                //       child: FutureBuilder(
                //           future: UniversalFunctions.getTopImages(context),
                //           builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
                //             if (snapshot.connectionState == ConnectionState.done) {
                //               var topImageSliders = new List<Widget>();
                //               if(snapshot.data != null ) {
                //                 topImageSliders = snapshot.data;
                //               } else {
                //                 topImageSliders = [
                //                   Container(
                //                       color: Colors.grey[300],
                //                       child: Center(
                //                           child: Icon(Icons.image_not_supported)
                //                       )
                //                   )
                //                 ];
                //               }
                //               print("got data below");
                //               print(topImageSliders);
                //               return
                //                 CarouselSlider(
                //                   items: topImageSliders,
                //                   options: CarouselOptions(
                //                       height: MediaQuery.of(context).size.height * 0.25,
                //                       autoPlay: true,
                //                       enlargeCenterPage: true,
                //                       aspectRatio: 2,
                //                       onPageChanged: (index, reason) {
                //                         // print(index);
                //                       }
                //                   ),
                //                 );
                //             } else {
                //               return Container(
                //                 color: Colors.grey,
                //                 child: SizedBox(
                //                   height: MediaQuery.of(context).size.height * 0.2,
                //                   child: SpinKitWave(
                //                     color: Colors.white,
                //                     size: 50.0,
                //                   ),
                //                 ),
                //               );
                //             }
                //           }
                //       ),
                //     ),
                //
                //     SizedBox(
                //       height: 10,
                //       child: Container(
                //         color: Colors.grey[300],
                //       ),
                //     ),
                //
                //     PostList(postType: widget.postType,),
                //
                //     SizedBox(height: 50,),
                //   ],
                // )
            )
        ),

    );
  }
}