
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'file:///C:/Projects/QandA/lib/customWidgets/ImageGridViewWidget.dart';
import 'file:///C:/Projects/QandA/lib/customWidgets/LikeAndCommentBarWidget.dart';
import 'file:///C:/Projects/QandA/lib/models/Post.dart';
import 'file:///C:/Projects/QandA/lib/pages/ShowPostPage.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostListWidget extends StatefulWidget{

  PostListWidget({Key key, this.postType}) : super(key: key);
  final String postType;

  @override
  _PostListWidgetState createState() => _PostListWidgetState();
}

class _PostListWidgetState extends State<PostListWidget>{

  List<int> data = [];
  final int increment = 5;
  bool isLoadingVertical = false;

  Column item(Post post) {
    return Column(
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
          child: ImageGridViewWidget(thumbnailAndImageUrls: post.thumbnailAndImageUrls, context: context) // UniversalWidgets.gridView(post.thumbnailAndImageUrls, context),
        ),

        LikeAndCommentBarWidget(context: context, post: post, pushToNewPage: true,),
        // UniversalWidgets.likeAndCommentBar(context, post, true),

        SizedBox(
          height: 10,
          child: Container(
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Future loadMore() async {

    print("load more called");
    setState(() {
      isLoadingVertical = true;
    });

    // Add in an artificial delay
    await new Future.delayed(const Duration(seconds: 2));

    data.addAll(
        List.generate(increment, (index) => data.length + index));

    setState(() {
      isLoadingVertical = false;
    });
  }

  var allPosts;

  void getPosts() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection(widget.postType)
            .get();

    setState(() {
      allPosts = result.docs.reversed;
    });
    // print(result.docs.toList());

  }

  @override
  void initState() {
    super.initState();
    getPosts();
    loadMore();
  }

  @override
  Widget build(BuildContext context) {
    // print("build view");

    if(allPosts == null) {
      return Center(child: Text("Loading"),);
    } else {
      // print(allPosts);
      if(allPosts.length == 0) {
        return Center(child: Text("No Content"),);
      } else {
        return LazyLoadScrollView(
            isLoading: isLoadingVertical,
            onEndOfPage: () => loadMore(),
            child: Scrollbar(
              child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length <= allPosts.length ? data.length : allPosts.length,
                itemBuilder: (context, position) {

                  if(data.length == position + 1) {
                    return Center(
                      child: SpinKitRipple(
                        color: Colors.blue,
                        size: 50.0,
                      ),
                    );
                  } else {
                    Post post = new Post();
                    post.setPostWithDocumentSnapshot(allPosts.elementAt(position));
                    return item(post);
                  }
                },
              ),
            )
        );
      }
    }


  }
}
