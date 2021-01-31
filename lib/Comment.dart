

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qanda/Post.dart';

class Comment {
  var content = "";
  var time;
  var byEmail = "";
  var by = "";
  var replies = List<Map>();

  Comment({
    var content,
    var time,
    var by,
    var byEmail,
  }){
    if(content != null){ this.content = content; }
    if(time != null){ this.time = time; }
    if(by != null){ this.by = by; }
    if(byEmail != null){ this.byEmail = byEmail; }
  }


  void create(Post post) {
    var topicLowerCase = post.topic.toLowerCase();

    FirebaseFirestore.instance.collection('$topicLowerCase posts')
        .doc(post.postDocName)
        .collection("comments")
        .doc(time.toString().split(".")[0] + " by " + byEmail)
        .set({
      "content": content,
      "time": time,
      "by": by,
      "by email": byEmail
    })
        .then((value) => print("Comment created"))
        .catchError((error) => print("Failed to create Comments: $error"));
  }


  printOut() {
    print("content: " + content);
    print("time: " + time.toString());
    print("by: " + by);
    print("by email: " + byEmail);
    print("replies: " + replies.toString());
  }

}