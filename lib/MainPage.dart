

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/UniversalValues.dart';
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
                  if(topImageWidgets.length == result.items.length) {
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

                  // forgot to commit, add main page and top images
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

                  Padding(
                    padding: EdgeInsets.all(0),
                    child: StreamBuilder<QuerySnapshot>(
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
                                  Padding(
                                      padding: EdgeInsets.only(top: 20, bottom: 15, left: 20, right: 20), // on the bottom there is often a ... or images, 20 feels a too large padding for bottom
                                      child: InkWell(
                                        onTap: () {
                                          print("tapped on Post: " + post.postDocName);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocTypePath: post.topic.toLowerCase() + " posts", postDocName: post.postDocName,),));

                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                            post.course != ""
                                                ?
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                post.course,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54
                                                ),
                                              ),
                                            )
                                                :
                                            SizedBox(height: 0,),

                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                post.title,
                                                maxLines: 100,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(3),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      post.author,
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(3),
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child:Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // this handles what if text is more than three lines
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: AutoSizeText(
                                                post.content,
                                                maxLines: 3,
                                                style: TextStyle(fontSize: 20),
                                                minFontSize: 15,
                                                maxFontSize: 15,
                                                overflowReplacement: Column( // This widget will be replaced.
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      post.content,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "......",
                                                      // style: TextStyle(color: Colors.red),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Align(
                                            //   alignment: Alignment.centerLeft,
                                            //   child: Text(
                                            //     post.content,
                                            //     maxLines: 3, // only display three lines
                                            //     overflow: TextOverflow.ellipsis,
                                            //   ),
                                            // ),

                                            // Align(
                                            //   alignment: Alignment.centerLeft,
                                            //   child: Text(
                                            //     ('\n'.allMatches(post.content).length + 1).toString(),
                                            //   ),
                                            // ),
                                            //
                                            // // if more content has more than 3 lines, we display ... in the end
                                            // ('\n'.allMatches(post.content).length + 1) > 3
                                            //     ?
                                            // Align(
                                            //   alignment: Alignment.centerLeft,
                                            //   child: Text(
                                            //     "...",
                                            //   ),
                                            // )
                                            //     :
                                            // SizedBox(height: 0,),
                                          ],
                                        ),
                                      ),
                                  ),

                                  // images

                                  Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: gridView(post.imageUrls),
                                  ),

                                  SizedBox(
                                    height: 10,
                                    child: Container(
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              );
                            postsList.add(contentToDisplay);
                          }
                        }
                        return Column(
                            children: postsList
                        );
                      },

                    ),
                  ),

                  SizedBox(height: 50,),
                ],
              )
          )
      )

    );
  }
}