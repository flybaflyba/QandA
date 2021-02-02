

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:qanda/UniversalWidgets.dart';
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
          title: Center(child: Text("BYU Hawaii"),),
        ),
        body: Center(
            child: Container(
                constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
                child: ListView(
                  children: [

                    // main page top images
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: FutureBuilder(
                          future: UniversalFunctions.getTopImages(context),
                          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
                            if (snapshot.connectionState == ConnectionState.done) {
                              var topImageSliders;
                              if(snapshot.data.length != 0 ) {
                                topImageSliders = snapshot.data;
                              } else {
                                topImageSliders = [];
                              }
                              print("got data below");
                              print(topImageSliders);
                              return
                                CarouselSlider(
                                  items: topImageSliders,
                                  options: CarouselOptions(
                                      height: MediaQuery.of(context).size.height * 0.25,
                                      autoPlay: true,
                                      enlargeCenterPage: true,
                                      aspectRatio: 2,
                                      onPageChanged: (index, reason) {
                                        // print(index);
                                      }
                                  ),
                                );
                            } else {
                              return Container(
                                color: Colors.grey,
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.2,
                                  child: SpinKitWave(
                                    color: Colors.white,
                                    size: 50.0,
                                  ),
                                ),
                              );
                            }
                          }
                      ),
                    ),

                    SizedBox(
                      height: 10,
                      child: Container(
                        color: Colors.grey[300],
                      ),
                    ),

                    UniversalWidgets.mainPostList(widget.postType),

                    SizedBox(height: 50,),
                  ],
                )
            )
        ),

    );
  }
}