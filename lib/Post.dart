
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Post {
  var title = "";
  var content = "";
  var authorEmail = "";
  var author = "";
  var postDocName = ""; // post document name is the created time utc in string + creator's email so that the collection is sorted automatically and no duplicates
  var topic = "";
  var course = "";
  var createdTime; // DateTime type, has timezone info
  List<Uint8List> imageUint8Lists = [];

  List<String> imageUrls = [];

  Post({
    var title,
    var content,
    var authorEmail,
    var author,
    var postDocName,
    var imageUint8Lists,
    var topic,
    var course,
    var createdTime,
  }){
    if(title != null){ this.title = title; }
    if(content != null){ this.content = content; }
    if(authorEmail != null){ this.authorEmail = authorEmail; }
    if(author != null){ this.author = author; }
    if(postDocName != null){ this.postDocName = postDocName; }
    if(topic != null){ this.topic = topic; }
    if(course != null){ this.course = course; }
    if(createdTime != null){ this.createdTime = createdTime; }
    if(imageUint8Lists != null){ this.imageUint8Lists = imageUint8Lists; }
  }

  void setPostWithDocumentSnapshot(DocumentSnapshot postDocumentSnapshot) {
    title = postDocumentSnapshot["title"];
    content = postDocumentSnapshot["content"];
    authorEmail = postDocumentSnapshot["author email"];
    author = postDocumentSnapshot["author"];
    postDocName = postDocumentSnapshot["post doc name"];
    imageUrls = postDocumentSnapshot["image urls"];
    topic = postDocumentSnapshot["topic"];
    course = postDocumentSnapshot["course"];
    createdTime = postDocumentSnapshot["created time"];
  }

  // upload images, and get their urls to store in the post doc
  Future<List<String>> uploadImages(List<Uint8List> imageUint8Lists) async {
    List<String> urls = List<String>();

    // notTODO optimize the solution of this bug
    // for some reason, this function finishes before the last image was uploaded, actually it does wait
    // the function does not wait for then to finish, that's why we are missing the last url
    // so we put something in the end, so that we don't miss any good url
    // this is to add an element in the end of the image list, so that we miss this url instead of a real image url, not a good way to solve the problem though
    // imageUint8Lists.add(Uint8List(1));
    for (Uint8List imageUint8List in imageUint8Lists) {
      // image name is created time plus a number, created time is also the post name
      // images are under the created time named folder for each post
      String name = postDocName + " - " + imageUint8Lists.indexOf(imageUint8List).toString();
      var topicLowerCase = topic.toLowerCase();
      Reference ref = FirebaseStorage.instance.ref('$topicLowerCase post Images/$postDocName/$name');
      // if we don't set this, it's not being recognized as image when web, might not be an issue, but I would like to set it
      SettableMetadata settableMetadata = SettableMetadata(contentType: 'image');
      try {
        // Upload raw data.
        await ref.putData(imageUint8List, settableMetadata);
            // .whenComplete(() {
            //   ref.getDownloadURL().then((value) {
            //     String imageUrl = value;
            //     print(imageUrl);
            //     urls.add(imageUrl);
            //     print(urls.length);
            //   });
            // });
        String url = await ref.getDownloadURL();
        print(url);
        urls.add(url);
        print(urls.length);
      } on FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
    }

    print("end of the uploading images");
    return urls;
    
  }


  Future<void> create() async {

    await uploadImages(imageUint8Lists)
        .then((urls) {
          print("after upload images function is done, we create post doc with url list ready");
          print(urls.length);
          imageUrls = urls;
          // url list is where the images are saved
          var topicLowerCase = topic.toLowerCase();
          FirebaseFirestore.instance.collection('$topicLowerCase posts')
              .doc(postDocName)
              .set({
            "title": title,
            "content": content,
            "author email": authorEmail,
            "author": author,
            "post doc name": postDocName,
            "topic" : topic,
            "course" : course,
            "created time": createdTime,
            "image urls": imageUrls,
          })
              .then((value) => print("Post Created"))
              .catchError((error) => print("Failed to create Post: $error"));
        });

  }

  void printOut() {
    print([
      title,
      content,
      authorEmail,
      author,
      postDocName,
      topic,
      course,
      createdTime,
      imageUrls,
      imageUint8Lists.length,
    ]);
  }
}

