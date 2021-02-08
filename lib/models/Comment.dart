

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qanda/models/Post.dart';

class Comment {
  var content = "";
  var time;
  var byEmail = "";
  var by = "";
  var commentDocName = "";
  var replies = List<dynamic>();
  var to = "";
  var toEmail = "";

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
    FirebaseFirestore.instance.collection('posts')
        .doc(post.postDocName)
        .collection("comments")
        .doc(time.toString().split(".")[0] + " by " + byEmail)
        .set({
      "content": content,
      "time": time,
      "by": by,
      "by email": byEmail,
      "replies": replies,
    })
        .then((value) => print("Comment created"))
        .catchError((error) => print("Failed to create Comments: $error"));
  }

  void update(Post post) {
    FirebaseFirestore.instance.collection('posts')
        .doc(post.postDocName)
        .collection("comments")
        .doc(commentDocName)
        .update({
      "content": content,
      "time": time,
      "by": by,
      "by email": byEmail,
      "replies": replies,
    })
        .then((value) => print("Comment created"))
        .catchError((error) => print("Failed to create Comments: $error"));
  }

  Map toMap() {
    return {"content": content, "time": time, "by": by, "by email": byEmail, "to": to, "to email": toEmail};
  }


  printOut() {
    print("content: " + content);
    print("time: " + time.toString());
    print("by: " + by);
    print("by email: " + byEmail);
    print("to: " + to);
    print("replies: " + replies.toString());
  }

}