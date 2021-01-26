
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
  var author = "";
  var createdTime = "";
  var topic = "";
  var course = "";
  List<Uint8List> imageUint8Lists = [];

  List<String> imageUrls = [];

  Post({
    var title,
    var content,
    var author,
    var createdTime,
    var imageUint8Lists,
    var topic,
    var course,
  }){
    if(title != null){ this.title = title; }
    if(content != null){ this.content = content; }
    if(author != null){ this.author = author; }
    if(createdTime != null){ this.createdTime = createdTime; }
    if(topic != null){ this.topic = topic; }
    if(course != null){ this.course = course; }
    if(imageUint8Lists != null){ this.imageUint8Lists = imageUint8Lists; }
  }

  void setPostWithDocumentSnapshot(DocumentSnapshot postDocumentSnapshot) {
    title = postDocumentSnapshot["title"];
    content = postDocumentSnapshot["content"];
    author = postDocumentSnapshot["author"];
    createdTime = postDocumentSnapshot["created time"];
    imageUrls = postDocumentSnapshot["image urls"];
    topic = postDocumentSnapshot["topic"];
    course = postDocumentSnapshot["course"];
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
      String name = createdTime + " - " + imageUint8Lists.indexOf(imageUint8List).toString();
      var topicLowerCase = topic.toLowerCase();
      Reference ref = FirebaseStorage.instance.ref('$topicLowerCase post Images/$createdTime/$name');
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
              .doc(createdTime)
              .set({
            "title": title,
            "content": content,
            "author": author,
            "created time": createdTime,
            "topic" : topic,
            "course" : course,
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
      author,
      createdTime,
      topic,
      course,
      imageUrls,
      imageUint8Lists.length,
    ]);
  }
}

