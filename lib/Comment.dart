

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qanda/Post.dart';

class Comment {
  var content = "";
  var time = "";
  var by = "";
  var replies = List<Map>();

  Comment({
    var content,
    var time,
    var by,
  }){
    if(content != null){ this.content = content; }
    if(time != null){ this.time = time; }
    if(by != null){ this.by = by; }
  }


  void create(Post post) {
    var topicLowerCase = post.topic.toLowerCase();

    FirebaseFirestore.instance.collection('$topicLowerCase posts')
        .doc(post.postDocName)
        .collection("comments")
        .doc(time + " by " + by)
        .set({
      "content": content,
      "time": time,
      "by": by
    })
        .then((value) => print("Comment updated"))
        .catchError((error) => print("Failed to update Comments: $error"));
  }


  printOut() {
    print("content: " + content);
    print("time: " + time);
    print("by: " + by);
    print("replies: " + replies.toString());
  }

}