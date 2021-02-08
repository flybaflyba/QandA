

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/models/Post.dart';
import 'package:qanda/pages/ShowPostPage.dart';
import 'package:qanda/pages/SignInUpPage.dart';
import 'package:qanda/universals/UniversalFunctions.dart';



class LikeAndCommentBarWidget extends StatelessWidget{


  BuildContext context;
  Post post;
  bool pushToNewPage;

  LikeAndCommentBarWidget({
    @required this.context,
  @required this.post,
  @required this.pushToNewPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // no need this if the post passed in is already from stream builder
          // StreamBuilder<DocumentSnapshot>(
          //     stream: FirebaseFirestore.instance
          //         .collection('${post.topic.toLowerCase()} posts')
          //         .doc(post.postDocName)
          //         .snapshots(),
          //     builder: (context, snapshot){
          //
          //       if(snapshot.hasData && snapshot != null) {
          //         Post postTempForLike = new Post();
          //         postTempForLike.postDocName = snapshot.data["post doc name"];
          //         postTempForLike.topic = snapshot.data["topic"];
          //         postTempForLike.likedBy = snapshot.data["liked by"];
          //         // postTempForLike.setPostWithDocumentSnapshot(snapshot.data);
          //         Color likeButtonColor;
          //         if (FirebaseAuth.instance.currentUser == null) {
          //           likeButtonColor = Colors.black;
          //         } else if (!snapshot.data["liked by"].contains(FirebaseAuth.instance.currentUser.email)){
          //           likeButtonColor = Colors.black;
          //         } else {
          //           likeButtonColor = Colors.blueAccent;
          //         }
          //         return Row(
          //           children: [
          //             IconButton(
          //                 icon: Icon(Icons.thumb_up_alt_outlined, color: likeButtonColor,),
          //                 onPressed: () {
          //                   print(postTempForLike.likedBy);
          //                   // if user want to like a post, check if logged in
          //                   if (FirebaseAuth.instance.currentUser != null) {
          //                     if(postTempForLike.likedBy.contains(FirebaseAuth.instance.currentUser.email)) {
          //                       postTempForLike.likedByUpdate(FirebaseAuth.instance.currentUser.email, "-");
          //                     } else {
          //                       postTempForLike.likedByUpdate(FirebaseAuth.instance.currentUser.email, "+");
          //                     }
          //                   } else {
          //                     // ask for login
          //                     print("ask for login");
          //                     pushNewScreen(
          //                       context,
          //                       screen: SignInUpPage(),
          //                       withNavBar: false, // OPTIONAL VALUE. True by default.
          //                       pageTransitionAnimation: PageTransitionAnimation.cupertino,
          //                     );
          //                   }
          //
          //                 }
          //             ),
          //             Text(postTempForLike.likedBy.length.toString()),
          //           ],
          //         );
          //       } else {
          //         return Row(
          //           children: [
          //             IconButton(icon: Icon(Icons.thumb_up_alt_outlined, color: Colors.black,),),
          //             Text("0"),
          //           ],
          //         );
          //       }
          //     }),

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
                  .collection('posts')
                  .doc(post.postDocName)
                  .collection("comments")
                  .snapshots(),
              builder: (context, snapshot){
                var numOfMainComment = 0;
                if(snapshot.hasData) {
                  // print("numOfMainComment is " + snapshot.data.docs.length.toString());
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocName: post.postDocName,),));
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
}

