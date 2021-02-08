
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qanda/customWidgets/ImageGridViewWidget.dart';
import 'package:qanda/customWidgets/LikeAndCommentBarWidget.dart';
import 'package:qanda/customWidgets/PostTileWidget.dart';
import 'package:qanda/models/Post.dart';
import 'package:qanda/pages/ShowPostPage.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostListWidget extends StatefulWidget{

  PostListWidget({Key key, this.postType, this.allPostsStream}) : super(key: key);
  final String postType;
  var allPostsStream;

  @override
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget>{

  List<int> data = [];
  final int increment = 10;
  // bool isLoadingVertical = false;
  // var allPosts;

  Widget item(int position) {

    // return Container(height: 100, child: Center(child: Text(position.toString()),),);

    // String id = widget.allPostsStream.elementAt(position).id;

    Post post = new Post();
    post.setPostWithDocumentSnapshot(widget.allPostsStream.elementAt(position));

    return PostTileWidget(position: position, post: post,);


    // return PostTileWidget(position: position, postType: widget.postType, id: id,);

    // this won't jump
    // return Column(
    //   children: [
    //     Padding(
    //       padding: EdgeInsets.only(top: 20, bottom: 15, left: 20, right: 20), // on the bottom there is often a ... or images, 20 feels a too large padding for bottom
    //       child: InkWell(
    //         onTap: () {
    //           print("tapped on Post: " + post.postDocName);
    //           Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocTypePath: post.topic.toLowerCase() + " posts", postDocName: post.postDocName,),));
    //         },
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             post.course != ""
    //                 ?
    //             Align(
    //               alignment: Alignment.centerLeft,
    //               child: Text(
    //                 post.course,
    //                 style: TextStyle(
    //                     fontSize: 13,
    //                     fontWeight: FontWeight.bold,
    //                     color: Colors.black54
    //                 ),
    //               ),
    //             )
    //                 :
    //             SizedBox(height: 0,),
    //
    //             // no need title
    //             // Align(
    //             //   alignment: Alignment.centerLeft,
    //             //   child: Text(
    //             //     post.title,
    //             //     maxLines: 100,
    //             //     style: TextStyle(
    //             //         fontSize: 20,
    //             //         fontWeight: FontWeight.bold
    //             //     ),
    //             //   ),
    //             // ),
    //
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Padding(
    //                   padding: EdgeInsets.all(3),
    //                   child: Align(
    //                     alignment: Alignment.centerLeft,
    //                     child: Text(
    //                       post.author + " " + position.toString(),
    //                       style: TextStyle(
    //                         fontSize: 15,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.all(3),
    //                   child: Align(
    //                     alignment: Alignment.centerRight,
    //                     child:Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //
    //             // this handles what if text is more than three lines
    //             Align(
    //               alignment: Alignment.centerLeft,
    //               child: AutoSizeText(
    //                 post.content,
    //                 maxLines: 3,
    //                 style: TextStyle(fontSize: 20),
    //                 minFontSize: 15,
    //                 maxFontSize: 15,
    //                 overflowReplacement: Column( // This widget will be replaced.
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: <Widget>[
    //                     Text(
    //                       post.content,
    //                       maxLines: 3,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                     Text(
    //                       "......",
    //                       // style: TextStyle(color: Colors.red),
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             // Align(
    //             //   alignment: Alignment.centerLeft,
    //             //   child: Text(
    //             //     post.content,
    //             //     maxLines: 3, // only display three lines
    //             //     overflow: TextOverflow.ellipsis,
    //             //   ),
    //             // ),
    //
    //             // Align(
    //             //   alignment: Alignment.centerLeft,
    //             //   child: Text(
    //             //     ('\n'.allMatches(post.content).length + 1).toString(),
    //             //   ),
    //             // ),
    //             //
    //             // // if more content has more than 3 lines, we display ... in the end
    //             // ('\n'.allMatches(post.content).length + 1) > 3
    //             //     ?
    //             // Align(
    //             //   alignment: Alignment.centerLeft,
    //             //   child: Text(
    //             //     "...",
    //             //   ),
    //             // )
    //             //     :
    //             // SizedBox(height: 0,),
    //           ],
    //         ),
    //       ),
    //     ),
    //
    //     // images
    //
    //     Padding(
    //         padding: EdgeInsets.only(bottom: 10),
    //         child: ImageGridViewWidget(thumbnailAndImageUrls: post.thumbnailAndImageUrls, context: context) // UniversalWidgets.gridView(post.thumbnailAndImageUrls, context),
    //     ),
    //
    //     LikeAndCommentBarWidget(context: context, post: post, pushToNewPage: true,),
    //
    //
    //     // UniversalWidgets.likeAndCommentBar(context, post, true),
    //
    //     SizedBox(
    //       height: 10,
    //       child: Container(
    //         color: Colors.grey[300],
    //       ),
    //     ),
    //   ],
    // );


    // return StreamBuilder<DocumentSnapshot>(
    //     stream: FirebaseFirestore.instance
    //         .collection(widget.postType)
    //         .doc(allPosts.elementAt(position).id)
    //         .snapshots(),
    //     builder: (context, snapshot){
    //       if(snapshot.hasData){
    //         DocumentSnapshot documentSnapshot = snapshot.data;
    //         Post post = new Post();
    //         if (documentSnapshot.data() == null) {
    //           // if the document is deleted
    //           return SizedBox(height: 0,);
    //         } else {
    //           post.setPostWithDocumentSnapshot(documentSnapshot);
    //           return Column(
    //             children: [
    //               Padding(
    //                 padding: EdgeInsets.only(top: 20, bottom: 15, left: 20, right: 20), // on the bottom there is often a ... or images, 20 feels a too large padding for bottom
    //                 child: InkWell(
    //                   onTap: () {
    //                     print("tapped on Post: " + post.postDocName);
    //                     Navigator.push(context, MaterialPageRoute(builder: (context) => ShowPostPage(postDocTypePath: post.topic.toLowerCase() + " posts", postDocName: post.postDocName,),));
    //                   },
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       post.course != ""
    //                           ?
    //                       Align(
    //                         alignment: Alignment.centerLeft,
    //                         child: Text(
    //                           post.course,
    //                           style: TextStyle(
    //                               fontSize: 13,
    //                               fontWeight: FontWeight.bold,
    //                               color: Colors.black54
    //                           ),
    //                         ),
    //                       )
    //                           :
    //                       SizedBox(height: 0,),
    //
    //                       // no need title
    //                       // Align(
    //                       //   alignment: Alignment.centerLeft,
    //                       //   child: Text(
    //                       //     post.title,
    //                       //     maxLines: 100,
    //                       //     style: TextStyle(
    //                       //         fontSize: 20,
    //                       //         fontWeight: FontWeight.bold
    //                       //     ),
    //                       //   ),
    //                       // ),
    //
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Padding(
    //                             padding: EdgeInsets.all(3),
    //                             child: Align(
    //                               alignment: Alignment.centerLeft,
    //                               child: Text(
    //                                 post.author + " " + position.toString(),
    //                                 style: TextStyle(
    //                                   fontSize: 15,
    //                                   fontWeight: FontWeight.bold,
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                           Padding(
    //                             padding: EdgeInsets.all(3),
    //                             child: Align(
    //                               alignment: Alignment.centerRight,
    //                               child:Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //
    //                       // this handles what if text is more than three lines
    //                       Align(
    //                         alignment: Alignment.centerLeft,
    //                         child: AutoSizeText(
    //                           post.content,
    //                           maxLines: 3,
    //                           style: TextStyle(fontSize: 20),
    //                           minFontSize: 15,
    //                           maxFontSize: 15,
    //                           overflowReplacement: Column( // This widget will be replaced.
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: <Widget>[
    //                               Text(
    //                                 post.content,
    //                                 maxLines: 3,
    //                                 overflow: TextOverflow.ellipsis,
    //                               ),
    //                               Text(
    //                                 "......",
    //                                 // style: TextStyle(color: Colors.red),
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                       // Align(
    //                       //   alignment: Alignment.centerLeft,
    //                       //   child: Text(
    //                       //     post.content,
    //                       //     maxLines: 3, // only display three lines
    //                       //     overflow: TextOverflow.ellipsis,
    //                       //   ),
    //                       // ),
    //
    //                       // Align(
    //                       //   alignment: Alignment.centerLeft,
    //                       //   child: Text(
    //                       //     ('\n'.allMatches(post.content).length + 1).toString(),
    //                       //   ),
    //                       // ),
    //                       //
    //                       // // if more content has more than 3 lines, we display ... in the end
    //                       // ('\n'.allMatches(post.content).length + 1) > 3
    //                       //     ?
    //                       // Align(
    //                       //   alignment: Alignment.centerLeft,
    //                       //   child: Text(
    //                       //     "...",
    //                       //   ),
    //                       // )
    //                       //     :
    //                       // SizedBox(height: 0,),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //
    //               // images
    //
    //               Padding(
    //                   padding: EdgeInsets.only(bottom: 10),
    //                   child: ImageGridViewWidget(thumbnailAndImageUrls: post.thumbnailAndImageUrls, context: context) // UniversalWidgets.gridView(post.thumbnailAndImageUrls, context),
    //               ),
    //
    //               LikeAndCommentBarWidget(context: context, post: post, pushToNewPage: true,),
    //
    //
    //               // UniversalWidgets.likeAndCommentBar(context, post, true),
    //
    //               SizedBox(
    //                 height: 10,
    //                 child: Container(
    //                   color: Colors.grey[300],
    //                 ),
    //               ),
    //             ],
    //           );
    //         }
    //       } else {
    //         return SizedBox(height: 0,);
    //         //   Center(
    //         //   child: Container(
    //         //     height: 100,
    //         //     child: SpinKitDualRing(
    //         //       color: Colors.blue,
    //         //       size: 50.0,
    //         //     ),
    //         //   )
    //         // );
    //       }
    //     }
    // );
  }

  // void getPosts() async {
  //   final QuerySnapshot result =
  //       await FirebaseFirestore.instance
  //           .collection(widget.postType)
  //           .get();
  //
  //   setState(() {
  //     allPosts = result.docs.reversed;
  //   });
  //   // print(result.docs.toList());
  //
  // }

  RefreshController refreshController =
  RefreshController(initialRefresh: true);

  void onRefresh() async{
    // monitor network fetch
    // getPosts();
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use refreshFailed()
    refreshController.refreshCompleted();
  }

  void onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 2000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    data.addAll(
        List.generate(increment, (index) => data.length + index));

    // if(data.length + 5 > allPosts.length) {
    //   data.addAll(
    //       List.generate(allPosts.length - data.length + 1, (index) => data.length + index));
    // } else {
    //   data.addAll(
    //       List.generate(increment, (index) => data.length + index));
    // }

    if(mounted)
      setState(() {
      });
    refreshController.loadComplete();
  }


  @override
  void initState() {
    super.initState();
    // getPosts();
    onLoading();
  }

  @override
  Widget build(BuildContext context) {
    // print("build view");

    if(widget.allPostsStream == null) {
      return Center(
        child: Container(
          color: Colors.grey[300],
          child: SpinKitCircle(
            color: Colors.blue,
            size: 50.0,
          ),
        ),
      );
    } else {
      // print(allPosts);
      if(widget.allPostsStream.length == 0) {
        return Center(child: Text("No Content"),);
      } else {
        return SmartRefresher(
          enableTwoLevel: true,
          enablePullDown: false,
          enablePullUp: data.length > widget.allPostsStream.length ? false : true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  Text("");
              }
              else if(mode==LoadStatus.loading){
                body =  SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
              else if(mode == LoadStatus.failed){
                body = Text("Load Failed! Click retry!");
              }
              else if(mode == LoadStatus.canLoading){
                body = Text("release to load more");
              }
              else{
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, position) {
              // return Container(height: 100, child: Center(child: Text("$position"),),);
              // print("one post build");
              if (widget.allPostsStream.length > position){
                return item(position);
              } else {
                return SizedBox(height: 0,);
              }
            },
            itemCount: data.length,
          ),
        );



        //   LazyLoadScrollView(
        //     isLoading: isLoadingVertical,
        //     onEndOfPage: () => loadMore(),
        //     child: Scrollbar(
        //       child: ListView.builder(
        //         // physics: NeverScrollableScrollPhysics(),
        //         shrinkWrap: true,
        //         itemCount: data.length <= allPosts.length ? data.length : allPosts.length,
        //         itemBuilder: (context, position) {
        //
        //           if(data.length == position + 1) {
        //             return Center(
        //               child: Padding(
        //                 padding: EdgeInsets.only(top: 10, bottom: 10),
        //                 child:  SpinKitThreeBounce(
        //                   color: Colors.blue,
        //                   size: 50.0,
        //                 ),
        //               )
        //             );
        //           } else {
        //             // Post post = new Post();
        //             // post.setPostWithDocumentSnapshot(allPosts.elementAt(position));
        //             return item(position);
        //           }
        //         },
        //       ),
        //     )
        // );


      }
    }


  }
}
