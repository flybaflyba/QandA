import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:qanda/customWidgets/LargeImagesPhotoWidget.dart';
import 'package:qanda/customWidgets/LikeAndCommentBarWidget.dart';
import 'package:qanda/customWidgets/NetworkImageWidget.dart';
import 'package:qanda/models/Comment.dart';
import 'package:qanda/models/Post.dart';
import 'package:qanda/pages/CreatePostPage.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ShowPostPage extends StatefulWidget{

  ShowPostPage({Key key,this.postDocName}) : super(key: key);
  var postDocName;

  @override
  _ShowPostPageState createState() => _ShowPostPageState();
}

class _ShowPostPageState extends State<ShowPostPage>{

  // int currentImageIndex = 0;
  // double imageSize = 0.3;

  var carouselController = new CarouselController();
  var pageController = new PageController();

  var appBarText = "";


  @override
  void initState() {
    super.initState();
    // this might be changed due to view images outside of show post page
    UniversalValues.currentViewingImageIndex = 0;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [

            widget.postDocName.contains(FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser.email : "user is not logged in and this sentence won't be in doc name so it returns false")
            ?
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: ()  async {

                  AwesomeDialog(
                    context: context,
                    useRootNavigator: true,
                    dialogType: DialogType.QUESTION,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Update your post?',
                    desc: "",
                    btnCancelText: "Delete",
                    btnCancelColor: Colors.red,
                    btnCancelOnPress: () {

                      AwesomeDialog(
                          context: context,
                          useRootNavigator: true,
                          dialogType: DialogType.INFO,
                          animType: AnimType.BOTTOMSLIDE,
                          title: 'Are you sure to delete?',
                          desc: "",
                          btnCancelText: "Delete",
                          btnCancelColor: Colors.red,
                          btnCancelOnPress: ()
                          {
                            // go to post page, then delete so that we don't see error because we try to show something that's deleted
                            Navigator.pop(context);
                            Future.delayed(Duration(milliseconds: 500)).then((_) async {
                              Post post = new Post(postDocName: widget.postDocName);
                              post.delete();
                            });

                          },
                          btnOkText: "Cancel",
                          btnOkColor: Colors.blueAccent,
                          btnOkOnPress: () {},
                          )..show();


                    },
                    btnOkText: "Edit",
                    btnOkColor: Colors.blueAccent,
                    btnOkOnPress: () async {
                      print("clicked on action button of view post page");
                      Post post = new Post();
                      DocumentSnapshot postDoc = await
                      FirebaseFirestore.instance
                          .collection("posts")
                          .doc(widget.postDocName).get();
                      post.setPostWithDocumentSnapshot(postDoc);
                      Navigator.pop(context);
                      pushNewScreen(
                        context,
                        screen: CreatePostPage(post: post,),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );

                    },
                  )..show();



                }
            )
                :
                Text("")
          ],
        ),
      body:  Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 800),
              child: ListView(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("posts")
                        .doc(widget.postDocName)
                        .snapshots(),
                    builder: (context, snapshot){
                      Widget contentToDisplay = Center(child: Text("Nothing here"),);
                      if(snapshot.hasData){
                        final content = snapshot.data;
                        // print(snapshot.data.data());
                        Post post = new Post();
                        post.setPostWithDocumentSnapshot(snapshot.data);

                        var imgList = post.thumbnailAndImageUrls.keys.toList();

                        // no need title
                        // appBarText = post.title;

                        final List<Widget> imageSliders = imgList.map((item) => Container(
                          child: InkWell(
                              onTap: () {
                                print("tapped an image");
                                print(UniversalValues.currentViewingImageIndex);
                                var pageController = PageController(initialPage: UniversalValues.currentViewingImageIndex);
                                Future<void> future = showCupertinoModalBottomSheet(
                                  // expand: false,
                                  // bounce: true,
                                    useRootNavigator: true,
                                    context: context,
                                    duration: Duration(milliseconds: 700),
                                    builder: (context) =>
                                        LargeImagesPhotoWidget(pageController: pageController, imageUrls: post.thumbnailAndImageUrls.values.toList(),)
                                );
                                future.then((void value) {
                                  print("bottom sheet closed");
                                  print(UniversalValues.currentViewingImageIndex);
                                  carouselController.animateToPage(UniversalValues.currentViewingImageIndex);
                                });
                              },
                              child:
                              ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                child: NetworkImageWidget(url: item, width: MediaQuery.of(context).size.width * 0.9,), // UniversalWidgets.myNetworkImage(item, MediaQuery.of(context).size.width * 0.9),


                                // Container(
                                //   color: Colors.grey[300],
                                //   child: Center(
                                //     child: Image.network(
                                //       item,
                                //       filterQuality: FilterQuality.low,
                                //       fit: BoxFit.cover,
                                //       width: MediaQuery.of(context).size.width * 0.9,
                                //       loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                //         if (loadingProgress == null) return child;
                                //         return SpinKitRipple(
                                //           color: Colors.blue,
                                //           size: 50.0,
                                //         );
                                //       },
                                //       errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                //         print("error loading network image");
                                //         return Icon(Icons.image_not_supported);
                                //       },
                                //     ),
                                //   )
                                // ),
                              )

                          ),
                        )).toList();

                        contentToDisplay =
                        Column(
                          children: [

                            // Center(child: Text(DateFormat.yMEd().add_jms().format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),
                            // Center(child: Text(timeago.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch))),),


                            // CarouselSlider(
                            //   options: CarouselOptions              //     height: MediaQuery.of(context).size.height,
                            //     viewportFraction: 1.0,
                            //     enlargeCenterPage: false,
                            //     // autoPlay: false,
                            //   ),
                            //   items: imgList.map((item) => Container(
                            //     child: Center(
                            //         child: Image.network(item, fit: BoxFit.cover, )
                            //     ),
                            //   )).toList(),
                            // ),

                            Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              child:
                              post.thumbnailAndImageUrls.length == 0 ?
                              SizedBox(height: 0,) :
                              Column(
                                  children: [
                                    CarouselSlider(
                                      items: imageSliders,
                                      carouselController: carouselController,
                                      options: CarouselOptions(
                                          height: MediaQuery.of(context).size.height * 0.3,
                                          autoPlay: false,
                                          enlargeCenterPage: true,
                                          aspectRatio: 2,
                                          onPageChanged: (index, reason) {
                                            // print(index);
                                            setState(() {
                                              UniversalValues.currentViewingImageIndex = index;
                                            });
                                          }
                                      ),
                                    ),
                                    // indicator
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: imgList.map((url) {
                                        int index = imgList.indexOf(url);
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
                                  ]
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(bottom: 1),
                              child:  Container(
                                // color: Colors.grey[300],
                                child: Column(
                                  children: [
                                    // no need title
                                    // TitleWidget(title: post.title,),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 20),
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Center(child: Text(post.topic + " " + post.course),),
                                          Center(child: Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(post.createdTime.microsecondsSinceEpoch)) + " by " + post.author),),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),


                            Container(
                              color: Colors.grey[300],
                              child: Padding(
                                padding: EdgeInsets.only(left: 50, right: 50, bottom: 20, top: 20),
                                child:
                                Container(
                                  child: Center(
                                    child: Text(
                                      post.content,
                                      maxLines: 100,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            LikeAndCommentBarWidget(context: context, post: post, pushToNewPage: false,),
                            // UniversalWidgets.likeAndCommentBar(context, post, false),
                            // SizedBox(height: 20, child: Container(color: Colors.white,),),

                            // FlatButton(
                            //   color: Colors.blueAccent,
                            //   textColor: Colors.white,
                            //   onPressed: () {
                            //     print(content);
                            //     post.printOut();
                            //   },
                            //   child: Center(child: Text("something here")),
                            // ),


                            // comments area
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection("posts")
                                    .doc(widget.postDocName)
                                    .collection("comments")
                                    .snapshots(),
                                builder: (context, snapshot){
                                  List<Widget> commentWidgets = [
                                  // Padding(
                                  //   padding: EdgeInsets.all(10),
                                  //   child: Center(
                                  //       child: Container(
                                  //         // color: Colors.grey[300],
                                  //         child: SpinKitRotatingPlain(
                                  //           color: Colors.blue,
                                  //           size: 50.0,
                                  //         ),
                                  //       )
                                  //
                                  //   ),
                                  // )
                                  ];
                                  if(snapshot.data != null) {
                                    commentWidgets.clear();
                                    print(snapshot.data.docs.length);
                                    for (DocumentSnapshot d in snapshot.data.docs) {
                                      // print(d["content"]);

                                      var commentContent = d["content"];
                                      var commentTime = d["time"];
                                      var commentByEmail = d["by email"];
                                      var commentBy = d["by"];

                                      Comment comment = new Comment(content: commentContent, time: commentTime, byEmail: commentByEmail, by: commentBy);
                                      comment.commentDocName = d.id;
                                      comment.replies = d["replies"];

                                      List<Widget> replyWidgets = [];

                                      for(Map r in comment.replies) {
                                        Comment reply = new Comment(content: r["content"], time: r["time"], byEmail: r["by email"], by: r["by"]);
                                        reply.to = r["to"];
                                        reply.toEmail = r["to email"];

                                        Widget oneReplyWidget =
                                        Padding(
                                          padding: EdgeInsets.only(left: 20, right: 5, top: 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.grey[300],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: InkWell(
                                                onTap: () {
                                                  print("tapped a reply");
                                                  UniversalFunctions.showCommentInput(context, post, comment, reply.by, reply.byEmail);
                                                },
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 5),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            child: Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(
                                                                reply.by + " @ " + reply.to,
                                                                style: TextStyle(
                                                                  // fontSize: 20,
                                                                    fontWeight: FontWeight.bold
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Align(
                                                                alignment: Alignment.centerRight,
                                                                child: Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(reply.time.microsecondsSinceEpoch)))

                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          reply.content,
                                                          maxLines: 100,
                                                          style: TextStyle(
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );

                                        replyWidgets.add(oneReplyWidget);

                                      }

                                      Widget oneComment =
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.grey[200],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: InkWell(
                                              onTap: () {
                                                print("tapped comment id: " + d.id);
                                                UniversalFunctions.showCommentInput(context, post, comment, comment.by, comment.byEmail);
                                              },
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(bottom: 5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              comment.by,
                                                              style: TextStyle(
                                                                // fontSize: 20,
                                                                  fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Text(timeAgo.format(DateTime.fromMicrosecondsSinceEpoch(comment.time.microsecondsSinceEpoch)))

                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        comment.content,
                                                        maxLines: 100,
                                                        style: TextStyle(
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  Column(
                                                    children: replyWidgets,
                                                  )



                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );

                                      commentWidgets.add(oneComment);
                                    }
                                  }


                                  return Column(
                                    children: commentWidgets,
                                  );
                                }
                            ),

                            SizedBox(height: 20,),
                          ],
                        );


                      }
                      return contentToDisplay;
                    },
                  ),

                ],
              )
          )
      )
    );
  }
}