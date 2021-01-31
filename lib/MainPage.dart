

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

class MainPage extends StatefulWidget{

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{


  Future<List<Widget>> getTopImages() async {
    List<Widget> topImageWidgets = List<Widget>();
    List<String> topImageUrls = List<String>();
    firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref("top images").listAll();
    for(firebase_storage.Reference ref in result.items){
      var url = await ref.getDownloadURL();
      print(url);
      topImageUrls.add(url);
      topImageWidgets.add(
          Container(
            child: InkWell(
                onTap: () {
                  print("tapped top image " + url);
                  // make sure top image urls are all collected
                  UniversalValues.currentViewingImageIndex = topImageUrls.indexOf(url);
                  if(topImageWidgets.length == result.items.length) {
                    UniversalValues.currentViewingImageIndex = topImageUrls.indexOf(url); // we need this so that indicator in large view is at the right position
                    var pageController = PageController(initialPage: topImageUrls.indexOf(url));
                    Future<void> future = showCupertinoModalBottomSheet(
                      // expand: false,
                      // bounce: true,
                        useRootNavigator: true,
                        context: context,
                        duration: Duration(milliseconds: 700),
                        builder: (context) =>
                            LargeImagesPhotoView(pageController: pageController, imageUrls: topImageUrls)
                    );
                    future.then((void value) {
                      print("bottom sheet closed");
                      UniversalValues.currentViewingImageIndex = 0; // try not to change it because we are not in show post page
                      print(UniversalValues.currentViewingImageIndex);
                    });
                  }
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
                        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Container(
                              color: Colors.grey[300],
                              child: SpinKitDoubleBounce(
                                color: Colors.blue,
                                size: 50.0,
                              ),
                            )
                            // CircularProgressIndicator(
                            //   value: loadingProgress.expectedTotalBytes != null ?
                            //   loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                            //       : null,
                            // ),
                          );
                        },
                      )
                  ),
                )
            ),
          )
      );
    }
    print("end of get top images");
    return topImageWidgets;
  }


  Widget gridView(List<dynamic> urls) {

    if(urls.length == 0) {
      // no image
      return SizedBox(height: 0,);
    } else {
      int crossAxisCount = 3;
      var numOfImages = urls.length;
      // lots of code, but easy to understand
      if(numOfImages == 1) {
        crossAxisCount = 1;
      } else if (numOfImages == 2) {
        crossAxisCount = 2;
      } else if (numOfImages == 3) {
        crossAxisCount = 3;
      } else if (numOfImages == 4) {
        crossAxisCount = 2;
      } else if (numOfImages == 5) {
        crossAxisCount = 3;
      } else if (numOfImages == 6) {
        crossAxisCount = 3;
      } else if (numOfImages == 7) {
        crossAxisCount = 3;
      } else if (numOfImages == 8) {
        crossAxisCount = 3;
      } else if (numOfImages == 9) {
        crossAxisCount = 3;
      }

      return GridView.count(
        physics: ScrollPhysics(), // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(urls.length, (index) {
          return InkWell(
            onTap: () {
              print("tapped image index " + index.toString() + " with url " + urls[index]);

              UniversalValues.currentViewingImageIndex = index; // we need this so that indicator in large view is at the right position
              var pageController = PageController(initialPage: index);
              Future<void> future = showCupertinoModalBottomSheet(
                // expand: false,
                // bounce: true,
                  useRootNavigator: true,
                  context: context,
                  duration: Duration(milliseconds: 700),
                  builder: (context) =>
                      LargeImagesPhotoView(pageController: pageController, imageUrls: urls)
              );
              future.then((void value) {
                print("bottom sheet closed");
                UniversalValues.currentViewingImageIndex = 0; // try not to change it because we are not in show post page
                print(UniversalValues.currentViewingImageIndex);
              });

            },
            child: Image.network(
              urls[index],
              fit: BoxFit.cover,
              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: Container(
                    color: Colors.grey[300],
                    child: SpinKitRipple(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                );
              },
            ),
          );
        }
        ),
      );
    }


  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Center(child: Text("BYU Hawaii"),),
              bottom:  TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.nightlife)),
                  Tab(icon: Icon(Icons.school)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Center(
                    child: Container(
                        constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
                        child: ListView(
                          children: [

                            // main page top images
                            Padding(
                              padding: EdgeInsets.all(20),
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

                            UniversalWidgets.mainPostList("campus life posts"),

                            SizedBox(height: 50,),
                          ],
                        )
                    )
                ),

                Center(
                    child: Container(
                        constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 10,
                              child: Container(
                                color: Colors.grey[300],
                              ),
                            ),

                            UniversalWidgets.mainPostList("academic posts"),

                            SizedBox(height: 50,),
                          ],
                        )
                    )
                ),
              ],
            )

        ),
      )
    );
  }
}