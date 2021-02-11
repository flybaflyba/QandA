

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nice_button/nice_button.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/customWidgets/PostListWidget.dart';
import 'package:qanda/customWidgets/SearchCourseWidget.dart';
import 'package:qanda/pages/EditPostPage.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostsPage extends StatefulWidget{
  PostsPage({Key key, @required this.postType, this.searchCourse, this.searchPerson}) : super(key: key);

  final postType;
  final searchCourse;
  final searchPerson;

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            widget.searchCourse == null ?
            Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(""),

                )
            ) :
            SizedBox(width: 0,),

            Text(
                widget.searchPerson != null
                    ?
                ""
                    :
                widget.postType == "academic posts"
                    ?
                widget.searchCourse == null
                    ?
                "Academic"
                    :
                widget.searchCourse
                    :
                "Campus Life"
            ),
            Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: (widget.postType == "academic posts" && widget.searchPerson == null) || (widget.postType == "academic posts" && widget.searchPerson == "") // searchPerson should be null, but for some reason, on web deployed it's "", ONLY DEPLOYED WEB
                      ?
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        print("search by subject");
                        AwesomeDialog(
                          context: context,
                          useRootNavigator: true,
                          animType: AnimType.SCALE,
                          dialogType: DialogType.QUESTION,
                          dialogBackgroundColor: Color(0x00000000),
                          body: SearchCourseWidget(),

                        )..show()
                            .then((value) {
                          print(value);
                          print("dialog closed");
                          print(UniversalValues.searchCourseTerm);
                          // push to course page then reset search term
                          if(UniversalValues.courses.contains(UniversalValues.searchCourseTerm)) {
                            var searchTerm = UniversalValues.searchCourseTerm;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PostsPage(postType: "academic posts", searchCourse: searchTerm,)));
                          }
                          UniversalValues.searchCourseTerm = "";
                        });
                      }
                  )
                      :
                  Text(""),
                )

            )
          ],
        ),
        // leading: widget.searchCourse == null ? Text("a") : BackButton(),
        actions: [


        ],
      ),
      body: Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child:
              Stack(
                children: [
                  //(((((((((((((((((((((((((((((((
                  widget.searchPerson == null
                      ?
                  //(((((((((((((((((((((((((((((((
                  widget.searchCourse == null
                      ?
                  StreamBuilder<QuerySnapshot>(
                    // TODO we might want to change this later
                    // right now, we use stream view, but when a user is viewing post list, the list might update as other people views it, and it takes more data
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .where("topic", isEqualTo: widget.postType == "academic posts" ? "Academic" : "Campus Life")
                          .orderBy('most recent activity time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          // var docs = snapshot.data.docs.reversed;
                          var docs = snapshot.data.docs;
                          print(docs.length);
                          return PostListWidget(allPostsStream: docs,);
                        } else {
                          return SpinKitRipple(
                            color: Colors.blue,
                            size: 50.0,
                          );
                        }
                      }
                  )
                      :
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .where("course", isEqualTo: widget.searchCourse)
                          .orderBy('most recent activity time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          var docs = snapshot.data.docs;
                          print(docs.length);
                          return PostListWidget(allPostsStream: docs,);
                        } else {
                          return SpinKitRipple(
                            color: Colors.blue,
                            size: 50.0,
                          );
                        }
                      }
                  )
                  //))))))))))))))))))))))))))))
                      :
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("posts")
                          .where("topic", isEqualTo: widget.postType == "academic posts" ? "Academic" : "Campus Life")
                          .where("author email", isEqualTo: widget.searchPerson)
                          .orderBy('most recent activity time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          var docs = snapshot.data.docs;
                          print(docs.length);
                          return PostListWidget(allPostsStream: docs,);
                        } else {
                          return SpinKitRipple(
                            color: Colors.blue,
                            size: 50.0,
                          );
                        }
                      }
                  ),
                  //))))))))))))))))))))))))))))
                ],
              )






            // if we put PostList in this ListView, lazy load won't load more
            // ListView(
            //   // physics: NeverScrollableScrollPhysics(),
            //   children: [
            //     // main page top images
            //     Padding(
            //       padding: EdgeInsets.all(20),
            //       child: FutureBuilder(
            //           future: UniversalFunctions.getTopImages(context),
            //           builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
            //             if (snapshot.connectionState == ConnectionState.done) {
            //               var topImageSliders = new List<Widget>();
            //               if(snapshot.data != null ) {
            //                 topImageSliders = snapshot.data;
            //               } else {
            //                 topImageSliders = [
            //                   Container(
            //                       color: Colors.grey[300],
            //                       child: Center(
            //                           child: Icon(Icons.image_not_supported)
            //                       )
            //                   )
            //                 ];
            //               }
            //               print("got data below");
            //               print(topImageSliders);
            //               return
            //                 CarouselSlider(
            //                   items: topImageSliders,
            //                   options: CarouselOptions(
            //                       height: MediaQuery.of(context).size.height * 0.25,
            //                       autoPlay: true,
            //                       enlargeCenterPage: true,
            //                       aspectRatio: 2,
            //                       onPageChanged: (index, reason) {
            //                         // print(index);
            //                       }
            //                   ),
            //                 );
            //             } else {
            //               return Container(
            //                 color: Colors.grey,
            //                 child: SizedBox(
            //                   height: MediaQuery.of(context).size.height * 0.2,
            //                   child: SpinKitWave(
            //                     color: Colors.white,
            //                     size: 50.0,
            //                   ),
            //                 ),
            //               );
            //             }
            //           }
            //       ),
            //     ),
            //
            //     SizedBox(
            //       height: 10,
            //       child: Container(
            //         color: Colors.grey[300],
            //       ),
            //     ),
            //
            //     PostList(postType: widget.postType,),
            //
            //     SizedBox(height: 50,),
            //   ],
            // )
          )
      ),

    );
  }
}