


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';

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

  static Widget largeImagesPhotoView(BuildContext context, PageController pageController, List<dynamic> imageUrls) {

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Stack(
            children: [
              Container(
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageUrls[index]),
                        initialScale: PhotoViewComputedScale.contained * 0.8,
                        heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                      );
                    },
                    itemCount: imageUrls.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                        ),
                      ),
                    ),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    pageController: pageController,
                    onPageChanged: (i) {
                      print(i);

                    },
                  )
              ),

              Positioned(
                top: 10,
                left: 0.0,
                right: 0.0,
                child:   Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageUrls.map((url) {
                    int index = imageUrls.indexOf(url);
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
              ),
            ],
          )
      );
    }
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
                    color: post.likedBy.contains(FirebaseAuth.instance.currentUser.email) ? Colors.blueAccent : Colors.black,
                  ),
                  onPressed: () {
                    if(post.likedBy.contains(FirebaseAuth.instance.currentUser.email)) {
                      post.likedByUpdate(FirebaseAuth.instance.currentUser.email, "-");
                    } else {
                      post.likedByUpdate(FirebaseAuth.instance.currentUser.email, "+");
                    }

                  }
              ),
              Text(post.likedBy.length.toString()),
            ],
          ),
          Row(
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
              Text("15"),
            ],
          ),
        ],
      ),
    );
  }



}