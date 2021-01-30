

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qanda/Post.dart';

class MainPage extends StatefulWidget{

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{


  Future<List<Widget>> getTopImages() async {
    List<Widget> topImageUrls = List<Widget>();
    firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref("top images").listAll();
    for(firebase_storage.Reference ref in result.items){
      var url = await ref.getDownloadURL();
      print(url);
      topImageUrls.add(
          Container(
            child: InkWell(
                onTap: () {
                },
                child:
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Center(
                      child: Image.network(
                        url,
                        filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                      )
                  ),
                )
            ),
          )
      );
    }
    print("end of get top images");
    return topImageUrls;

  }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("BYU Hawaii"),),
      ),
      body:
      Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: ListView(
                children: [

                  // Column(
                  //     children: [
                  //       CarouselSlider(
                  //         items: topImageSliders,
                  //         options: CarouselOptions(
                  //             height: MediaQuery.of(context).size.height * 0.3,
                  //             autoPlay: false,
                  //             enlargeCenterPage: true,
                  //             aspectRatio: 2,
                  //             onPageChanged: (index, reason) {
                  //               // print(index);
                  //             }
                  //         ),
                  //       ),
                  //     ]
                  // ),

                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder(
                        future: getTopImages(),
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
                                    height: MediaQuery.of(context).size.height * 0.2,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2,
                                    onPageChanged: (index, reason) {
                                      // print(index);
                                    }
                                ),
                              );
                          } else {
                            return Container(
                              color: Colors.greenAccent,
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

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('academic posts')
                        .snapshots(),
                    builder: (context, snapshot){
                      List<Widget> postsList = [];
                      if(snapshot.hasData){
                        final content = snapshot.data.docs;
                        for(var postDocumentSnapshot in content){
                          Post post = new Post();
                          post.setPostWithDocumentSnapshot(postDocumentSnapshot);
                          final contentToDisplay =
                          Column(
                            children: [
                              FlatButton(
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                  onPressed: () {
                                  },
                                  child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          post.title,
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              SizedBox(height: 10,),
                            ],
                          );
                          postsList.add(contentToDisplay);
                        }
                      }
                      return Column(
                          children: postsList
                      );
                    },

                  )
                ],
              )
          )
      )

    );
  }
}