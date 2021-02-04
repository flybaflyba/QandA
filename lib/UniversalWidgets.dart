


import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/SignInUpPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UniversalWidgets {

  static Widget titleWidget(String title) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
            )
        ),
      ],
    );
  }

  static Widget myNetworkImage(String url, double width) {
    return Container(
        color: Colors.grey[300],
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: width,
          filterQuality: FilterQuality.high,
          loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return SpinKitRipple(
              color: Colors.blue,
              size: 50.0,
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
            print("error loading network image");
            return Icon(Icons.image_not_supported);
          },
        ),
    );
  }

  static Widget likeAndCommentBar(BuildContext context, Post post, bool pushToNewPage) {

    return  Padding(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    // if user is not logged in, no email can be accessed
                    color:
                    FirebaseAuth.instance.currentUser == null
                        ?
                    Colors.black
                        :
                    post.likedBy.contains(FirebaseAuth.instance.currentUser.email)
                        ?
                    Colors.blueAccent
                        :
                    Colors.black,
                  ),
                  onPressed: () {
                    // if user want to like a post, check if logged in
                    if (FirebaseAuth.instance.currentUser != null) {
                      if(post.likedBy.contains(FirebaseAuth.instance.currentUser.email)) {
                        post.likedByUpdate(FirebaseAuth.instance.currentUser.email, "-");
                      } else {
                        post.likedByUpdate(FirebaseAuth.instance.currentUser.email, "+");
                      }
                    } else {
                      // ask for login
                      print("ask for login");
                      pushNewScreen(
                        context,
                        screen: SignInUpPage(),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    }

                  }
              ),
              Text(post.likedBy.length.toString()),
            ],
          ),

          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('${post.topic.toLowerCase()} posts')
                  .doc(post.postDocName)
                  .collection("comments")
                  .snapshots(),
              builder: (context, snapshot){
                var numOfMainComment = 0;
                if(snapshot.hasData) {
                  print("numOfMainComment is " + snapshot.data.docs.length.toString());
                  numOfMainComment = numOfMainComment + snapshot.data.docs.length;
                  snapshot.data.docs.forEach((doc) {
                    // print(doc["replies"].length.toString());
                    numOfMainComment = numOfMainComment + doc["replies"].length;
                  });
                }

                return Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.comment_bank_outlined),
                        onPressed: () {
                          if(pushToNewPage) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocTypePath: post.topic.toLowerCase() + " posts", postDocName: post.postDocName,),));
                          }
                          UniversalFunctions.showCommentInput(context, post, null, post.author, post.authorEmail);
                        }
                    ),
                    Text(numOfMainComment.toString()),
                  ],
                );
              }
          ),

        ],
      ),
    );
  }

  static Widget gridView(Map<dynamic, dynamic> thumbnailAndImageUrls, BuildContext context) {

    var urls = thumbnailAndImageUrls.keys.toList();

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
                      LargeImagesPhotoView(pageController: pageController, imageUrls: thumbnailAndImageUrls.values.toList(),)
              );
              future.then((void value) {
                print("bottom sheet closed");
                UniversalValues.currentViewingImageIndex = 0; // try not to change it because we are not in show post page
                print(UniversalValues.currentViewingImageIndex);
              });

            },
            child: Container(
              child: myNetworkImage(urls[index], null),
            )
          );
        }
        ),
      );
    }


  }

  static Widget mainPostList(String postType) {

    return Padding(
      padding: EdgeInsets.all(0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(postType)
            .snapshots(),
        builder: (context, snapshot){
          List<Widget> postsList = [];
          if(snapshot.hasData){
            final content = snapshot.data.docs.reversed;

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
                                      fontSize: 15,
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
                    child: gridView(post.thumbnailAndImageUrls, context),
                  ),

                  UniversalWidgets.likeAndCommentBar(context, post, true),

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
    );
  }





}