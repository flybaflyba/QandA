
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  var title = "";
  var content = "";
  var author = "";
  var createdTime = "";


  Post({
    var title,
    var content,
    var author,
    var createdTime,
  }){
    if(title != null){ this.title = title; }
    if(content != null){ this.content = content; }
    if(author != null){ this.author = author; }
    if(createdTime != null){ this.createdTime = createdTime; }
  }

  void setPostWithDocumentSnapshot(DocumentSnapshot postDocumentSnapshot) {
    title = postDocumentSnapshot["title"];
    content = postDocumentSnapshot["content"];
    author = postDocumentSnapshot["author"];
    createdTime = postDocumentSnapshot["created time"];
  }

  void create() {
    FirebaseFirestore.instance.collection('posts')
        .doc(createdTime)
        .set({
      "title": title,
      "content": content,
      "author": author,
      "createdTime": createdTime,
    })
        .then((value) => print("Post Created"))
        .catchError((error) => print("Failed to create Post: $error"));
  }

  void printOut() {
    print([
      title,
      content,
      author,
      createdTime,
    ]);
  }
}

