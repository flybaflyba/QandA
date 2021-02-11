
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

  PostListWidget({Key key, this.allPostsStream}) : super(key: key);
  var allPostsStream;

  @override
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget>{

  List<int> data = [];
  final int increment = 7;
  // bool isLoadingVertical = false;
  // var allPosts;

  Widget item(int position) {

    Post post = new Post();
    post.setPostWithDocumentSnapshot(widget.allPostsStream.elementAt(position));

    return PostTileWidget(position: position, post: post,);

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

  RefreshController refreshController = RefreshController(initialRefresh: true);

  var showLoader = true;

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

    Future.delayed(Duration(milliseconds: 2000)).then((_) async {
      setState(() {
        showLoader = false;
      });
    });

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
        return Stack(
          children: [

            Center(
              child: SmartRefresher(
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
                  // shrinkWrap: true,
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
              ),
            ),

            showLoader ?
            Center(
                child: Container(
                  color: Colors.grey[300],
                  child: Expanded(
                    child: SpinKitChasingDots(
                      color: Colors.blueAccent,
                      size: 50.0,
                    ),
                  ),
                )
            ) :
            SizedBox(height: 0,)


          ],
        );




      }
    }


  }
}
