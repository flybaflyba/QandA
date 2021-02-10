
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanda/customWidgets/ImageGridViewWidget.dart';
import 'package:qanda/customWidgets/LikeAndCommentBarWidget.dart';
import 'package:qanda/models/Post.dart';
import 'package:qanda/pages/ShowPostPage.dart';
import 'package:timeago/timeago.dart' as timeAgo;



class PostTileWidget extends StatelessWidget{

  final int position;
  // final String postType;
  // final String id;
  var post;

  PostTileWidget({
    @required this.position,
    // @required this.postType,
    // @required this.id,
    @required this.post,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, bottom: 15, left: 20, right: 20), // on the bottom there is often a ... or images, 20 feels a too large padding for bottom
          child: InkWell(
            onTap: () {
              print("tapped on Post: " + post.postDocName);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocName: post.postDocName,),));
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

                // no need title
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     post.title,
                //     maxLines: 100,
                //     style: TextStyle(
                //         fontSize: 20,
                //         fontWeight: FontWeight.bold
                //     ),
                //   ),
                // ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(post.authorEmail)
                            .snapshots(),
                        builder: (context, snapshot){
                          if(snapshot.hasData) {
                            post.authorImageUrl = snapshot.data.data()["profile image url"];
                            post.author = snapshot.data.data()["name"];

                          }
                          return Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(3),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                          border: Border.all(color: const Color(0x33A6A6A6)),
                                          image: DecorationImage(
                                              image:
                                              post.authorImageUrl == ""
                                                  ?
                                              AssetImage('assets/images/no_photo.png',)
                                                  :
                                              NetworkImage(post.authorImageUrl),
                                              fit: BoxFit.fill)
                                      ),
                                    )
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.all(3),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    post.author + " " + position.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
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

              ],
            ),
          ),
        ),


        Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ImageGridViewWidget(thumbnailAndImageUrls: post.thumbnailAndImageUrls, context: context) // UniversalWidgets.gridView(post.thumbnailAndImageUrls, context),
        ),

        LikeAndCommentBarWidget(context: context, post: post, pushToNewPage: true,),

        SizedBox(
          height: 10,
          child: Container(
            color: Colors.grey[300],
          ),
        ),
      ],
    );

  }

}