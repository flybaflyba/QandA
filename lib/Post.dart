
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:qanda/Comment.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';

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
  // List<dynamic> imageUrls = [];

  // no need to set when create post locally, but do need when save to database
  List<dynamic> likedBy = [];
  List<dynamic> comments = [];
  Map thumbnailAndImageUrls = Map<dynamic, dynamic>();

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
    // title = postDocumentSnapshot["title"];
    // content = postDocumentSnapshot["content"];
    // authorEmail = postDocumentSnapshot["author email"];
    // author = postDocumentSnapshot["author"];
    // postDocName = postDocumentSnapshot["post doc name"];
    // imageUrls = postDocumentSnapshot["image urls"];
    // topic = postDocumentSnapshot["topic"];
    // course = postDocumentSnapshot["course"];
    // createdTime = postDocumentSnapshot["created time"];
    // likedBy = postDocumentSnapshot["liked by"];
    // comments = postDocumentSnapshot["comments"];

    title = postDocumentSnapshot.data().keys.contains("title") ? postDocumentSnapshot["title"] : "";
    content = postDocumentSnapshot.data().keys.contains("content") ? postDocumentSnapshot["content"] : "";
    authorEmail = postDocumentSnapshot.data().keys.contains("author email") ? postDocumentSnapshot["author email"] : "";
    author = postDocumentSnapshot.data().keys.contains("author") ? postDocumentSnapshot["author"] : "";
    postDocName = postDocumentSnapshot.data().keys.contains("post doc name") ? postDocumentSnapshot["post doc name"] : "";
    // imageUrls = postDocumentSnapshot.data().keys.contains("image urls") ? postDocumentSnapshot["image urls"] : [];
    topic = postDocumentSnapshot.data().keys.contains("topic") ? postDocumentSnapshot["topic"] : "";
    course = postDocumentSnapshot.data().keys.contains("course") ? postDocumentSnapshot["course"] : "";
    createdTime = postDocumentSnapshot.data().keys.contains("created time") ? postDocumentSnapshot["created time"] : "";
    likedBy = postDocumentSnapshot.data().keys.contains("liked by") ? postDocumentSnapshot["liked by"] : "";
    // comments = postDocumentSnapshot.data().keys.contains("comments") ? postDocumentSnapshot["comments"] : [];
    thumbnailAndImageUrls = postDocumentSnapshot.data().keys.contains("thumbnail and image urls") ? postDocumentSnapshot["thumbnail and image urls"] : Map();
  }

  // upload images, and get their urls to store in the post doc
  Future<Map<dynamic, dynamic>> uploadImages(List<Uint8List> imageUint8Lists) async {
    // List<String> urls = List<String>();
    Map urls = Map();

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


      // create a thumbnail to store in the data base, we don't need the larger image every time
      imagePackage.Image image = imagePackage.decodeImage(imageUint8List);
      imagePackage.Image thumbnail = imagePackage.copyResize(image, width: 100);
      Reference ref2 = FirebaseStorage.instance.ref('$topicLowerCase post Images/$postDocName/$name thumbnail');
      Uint8List thumbnailUint8list = imagePackage.encodePng(thumbnail);


      // if we don't set this, it's not being recognized as image when web, might not be an issue, but I would like to set it
      SettableMetadata settableMetadata = SettableMetadata(contentType: 'image');
      try {
        // Upload raw data.
        await ref.putData(imageUint8List, settableMetadata)
            .catchError((e){
              print("image upload failed due to error $e");
            }
        );
        await ref2.putData(thumbnailUint8list, settableMetadata)
            .catchError((e){
              print("thumbnail upload failed due to error $e");
            }
        );
        String imageUrl = await ref.getDownloadURL();
        // print(imageUrl);
        String thumbnailUrl = await ref2.getDownloadURL();
        urls[thumbnailUrl] = imageUrl;
        print(urls.length);
      } on FirebaseException catch (e) {
        print("image upload failed due to error $e");
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
          // imageUrls = urls;
          thumbnailAndImageUrls = urls;
          if(thumbnailAndImageUrls.length != imageUint8Lists.length) {
            UniversalFunctions.showToast("Image uploading failed", UniversalValues.toastMessageTypeWarningColor);
          }
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
            // "image urls": imageUrls,
            "liked by": likedBy,
            "comments": comments,
            "thumbnail and image urls": thumbnailAndImageUrls
          })
              .then((value) => print("Post Created"))
              .catchError((error) => print("Failed to create Post: $error"));
        });

  }

  void likedByUpdate(String actionUserEmail, String action) {
    if(action == "+") {
      print("likedBy add one " + actionUserEmail);
      likedBy.add(actionUserEmail);
    } else if(action == "-"){
      print("likedBy minus one " + actionUserEmail);
      likedBy.remove(actionUserEmail);
    } else{
      print("invalid action");
    }
    var topicLowerCase = topic.toLowerCase();
    FirebaseFirestore.instance.collection('$topicLowerCase posts')
        .doc(postDocName)
        .update({
      "liked by": likedBy,
    })
        .then((value) => print("likedBy updated"))
        .catchError((error) => print("Failed to update likedBy: $error"));
  }

  void printOut() {
    print("title: " + title);
    print("content: " + content);
    print("authorEmail: " + authorEmail);
    print("author: " + author);
    print("postDocName: " + postDocName);
    print("topic: " + topic);
    print("course: " + course);
    print("createdTime: " + createdTime.toString());
    // print("imageUrls： " + imageUrls.toString());
    print("imageUint8Lists.length： " + imageUint8Lists.length.toString());
    print("comments: " + comments.toString());
    print("thumbnailAndImageUrls: " + thumbnailAndImageUrls.toString());
  }
}

