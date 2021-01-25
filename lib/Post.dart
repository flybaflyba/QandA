
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
  List<Uint8List> imageUint8Lists = [];

  List<String> imageUrls = [];

  Post({
    var title,
    var content,
    var author,
    var createdTime,
    var imageUint8Lists,
  }){
    if(title != null){ this.title = title; }
    if(content != null){ this.content = content; }
    if(author != null){ this.author = author; }
    if(createdTime != null){ this.createdTime = createdTime; }
    if(imageUint8Lists != null){ this.imageUint8Lists = imageUint8Lists; }
  }

  void setPostWithDocumentSnapshot(DocumentSnapshot postDocumentSnapshot) {
    title = postDocumentSnapshot["title"];
    content = postDocumentSnapshot["content"];
    author = postDocumentSnapshot["author"];
    createdTime = postDocumentSnapshot["created time"];
    imageUrls = postDocumentSnapshot["image urls"];
  }

  // upload images, and get their urls to store in the post doc
  Future<void> uploadImages(List<Uint8List> imageUint8Lists) async {
    for (Uint8List imageUint8List in imageUint8Lists) {

      // image name is created time plus a number, created time is also the post name
      // images are under the created time named folder for each post
      String name = createdTime + " - " + imageUint8Lists.indexOf(imageUint8List).toString();
      Reference ref = FirebaseStorage.instance.ref('post Images/$createdTime/$name');

      // if we don't set this, it's not being recognized as image when web, might not be an issue, but I would like to set it
      SettableMetadata settableMetadata = SettableMetadata(contentType: 'image');

      try {
        // Upload raw data.
        await ref.putData(imageUint8List, settableMetadata).whenComplete(() {
          ref.getDownloadURL().then((value) {
            String imageUrl = value;
            print(imageUrl);
            imageUrls.add(imageUrl);
          });
        });
      } on FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
      print(imageUrls.length);
    }
    print("end of the uploading images");
  }


  Future<void> create() async {

    await uploadImages(imageUint8Lists)
        .then((value) {
          print("after upload images function is done, we create post doc with url list ready");
          // url list is where the images are saved
          FirebaseFirestore.instance.collection('posts')
              .doc(createdTime)
              .set({
            "title": title,
            "content": content,
            "author": author,
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
      author,
      createdTime,
      imageUint8Lists.length,
      imageUrls,
    ]);
  }
}

