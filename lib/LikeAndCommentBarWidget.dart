

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/SignInUpPage.dart';
import 'package:qanda/UniversalFunctions.dart';



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
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('${post.topic.toLowerCase()} posts')
                  .doc(post.postDocName)
                  .snapshots(),
              builder: (context, snapshot){

                if(snapshot.hasData) {
                  Post postTempForLike = new Post();
                  postTempForLike.postDocName = snapshot.data["post doc name"];
                  postTempForLike.topic = snapshot.data["topic"];
                  postTempForLike.likedBy = snapshot.data["liked by"];
                  // postTempForLike.setPostWithDocumentSnapshot(snapshot.data);
                  Color likeButtonColor;
                  if (FirebaseAuth.instance.currentUser == null) {
                    likeButtonColor = Colors.black;
                  } else if (!snapshot.data["liked by"].contains(FirebaseAuth.instance.currentUser.email)){
                    likeButtonColor = Colors.black;
                  } else {
                    likeButtonColor = Colors.blueAccent;
                  }
                  return Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.thumb_up_alt_outlined, color: likeButtonColor,),
                          onPressed: () {
                            print(postTempForLike.likedBy);
                            // if user want to like a post, check if logged in
                            if (FirebaseAuth.instance.currentUser != null) {
                              if(postTempForLike.likedBy.contains(FirebaseAuth.instance.currentUser.email)) {
                                postTempForLike.likedByUpdate(FirebaseAuth.instance.currentUser.email, "-");
                              } else {
                                postTempForLike.likedByUpdate(FirebaseAuth.instance.currentUser.email, "+");
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
                      Text(postTempForLike.likedBy.length.toString()),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      IconButton(icon: Icon(Icons.thumb_up_alt_outlined, color: Colors.black,),),
                      Text("0"),
                    ],
                  );
                }
              }),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('${post.topic.toLowerCase()} posts')
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
}

