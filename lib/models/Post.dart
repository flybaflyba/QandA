
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';

class Post {
  var title = "";
  var content = "";
  var authorEmail = "";
  var author = "";
  var postDocName = ""; // post document name is the created time utc in string + creator's email so that the collection is sorted automatically and no duplicates
  var topic = "";
  var course = "";
  var createdTime; // DateTime type, has timezone info
  List<dynamic> imageUint8Lists = [];
  // List<dynamic> imageUrls = [];

  // no need to set when create post locally, but do need when save to database
  List<dynamic> likedBy = [];
  List<dynamic> comments = [];
  Map thumbnailAndImageUrls = Map<dynamic, dynamic>();
  var authorImageUrl = "";

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
    var authorImageUrl,
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
    if(authorImageUrl != null){ this.authorImageUrl = authorImageUrl; }
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
    authorImageUrl = postDocumentSnapshot.data().keys.contains("author image url") ? postDocumentSnapshot["author image url"] : "";
  }

  // upload images, and get their urls to store in the post doc
  Future<Map<dynamic, dynamic>> uploadImages(List<dynamic> imageUint8Lists) async {
    // List<String> urls = List<String>();
    Map urls = Map();

    // notTODO optimize the solution of this bug
    // for some reason, this function finishes before the last image was uploaded, actually it does wait
    // the function does not wait for then to finish, that's why we are missing the last url
    // so we put something in the end, so that we don't miss any good url
    // this is to add an element in the end of the image list, so that we miss this url instead of a real image url, not a good way to solve the problem though
    // imageUint8Lists.add(Uint8List(1));

    var dateTimeNow = DateTime.now();
    var dateTimeLast = DateTime.now();

    for (var imageUint8List in imageUint8Lists) {

      if(imageUint8List.runtimeType == String) {
        // do nothing, if we are updating post, this might already be the url.
      } else {
        dateTimeNow = DateTime.now();
        print("start one image processing at index ${imageUint8Lists.indexOf(imageUint8List).toString()} " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
        dateTimeLast = DateTime.now();

        // image name is created time plus a number, created time is also the post name
        // images are under the created time named folder for each post
        String name = postDocName + " - " + imageUint8Lists.indexOf(imageUint8List).toString();
        Reference ref = FirebaseStorage.instance.ref('post images/$postDocName/$name');

        Fluttertoast.cancel();
        UniversalFunctions.showToast("Processing Image ${(imageUint8Lists.indexOf(imageUint8List) + 1).toString()}", UniversalValues.toastMessageTypeGoodColor);
        dateTimeNow = DateTime.now();
        print("start creating thumbnail");
        dateTimeLast = DateTime.now();

        // create a thumbnail to store in the data base, we don't need the larger image every time
        imagePackage.Image image = imagePackage.decodeImage(imageUint8List); // TODO this process of is taking long time only ON WEB
        dateTimeNow = DateTime.now();
        print("decoding image took " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
        dateTimeLast = DateTime.now();
        imagePackage.Image thumbnail = imagePackage.copyResize(image, width: 200);
        dateTimeNow = DateTime.now();
        print("resizing image took " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
        dateTimeLast = DateTime.now();
        Reference ref2 = FirebaseStorage.instance.ref('post images/$postDocName/$name thumbnail');
        Uint8List thumbnailUint8list = imagePackage.encodePng(thumbnail);
        // Uint8List thumbnailUint8list = imageUint8List;

        dateTimeNow = DateTime.now();
        print("end of creating thumbnail (encoding image took) " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
        dateTimeLast = DateTime.now();

        // if we don't set this, it's not being recognized as image when web, might not be an issue, but I would like to set it
        SettableMetadata settableMetadata = SettableMetadata(contentType: 'image');
        try {
          Fluttertoast.cancel();
          UniversalFunctions.showToast("Uploading Image ${(imageUint8Lists.indexOf(imageUint8List) + 1).toString()}", UniversalValues.toastMessageTypeGoodColor);
          // Upload raw data.
          await ref.putData(imageUint8List, settableMetadata)
              .timeout((Duration(seconds: 10)), onTimeout: () {
            UniversalFunctions.showToast("Your internet is too slow", UniversalValues.toastMessageTypeWarningColor);
            return null;
          })
              .catchError((e){
            print("image upload failed due to error $e");
          });
          await ref2.putData(thumbnailUint8list, settableMetadata)
              .catchError((e){
            print("thumbnail upload failed due to error $e");
          }
          );
          String imageUrl = await ref.getDownloadURL();
          // print(imageUrl);
          String thumbnailUrl = await ref2.getDownloadURL();
          urls[thumbnailUrl] = imageUrl;
          // print(urls.length);
        } on FirebaseException catch (e) {
          print("image upload failed due to error $e");
        }

        dateTimeNow = DateTime.now();
        print("end of one image processing " + dateTimeNow.difference(dateTimeLast).inSeconds.toString());
        dateTimeLast = DateTime.now();
      }



    }

    print("end of the uploading images");

    // thumbnailAndImageUrls = urls;
    // if(thumbnailAndImageUrls.length != imageUint8Lists.length) {
    //   UniversalFunctions.showToast("Image uploading failed", UniversalValues.toastMessageTypeWarningColor);
    // }
    // // url list is where the images are saved
    // var topicLowerCase = topic.toLowerCase();
    // FirebaseFirestore.instance.collection('$topicLowerCase posts')
    //     .doc(postDocName)
    //     .update({
    //   "thumbnail and image urls": thumbnailAndImageUrls
    // })
    //     .then((value) => print("Post image urls saved"))
    //     .catchError((error) => print("Failed to saved Post urls: $error"));


    return urls;
  }

  Future<void> create() async {

    await uploadImages(imageUint8Lists)
        .then((urls) {
          print("after upload images function is done, we create post doc with url list ready");
          print(urls.length);
          // imageUrls = urls;
          // the post might already have links if it's editing.
          for(var u in urls.keys.toList()){
            thumbnailAndImageUrls[u] = urls[u];
          }
          // thumbnailAndImageUrls = urls;
          print("${thumbnailAndImageUrls.length} and ${imageUint8Lists.length}");
          if(thumbnailAndImageUrls.length != imageUint8Lists.length) {
            UniversalFunctions.showToast("Image uploading failed", UniversalValues.toastMessageTypeWarningColor);
          }
          // url list is where the images are saved
          FirebaseFirestore.instance.collection('posts')
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
            "thumbnail and image urls": thumbnailAndImageUrls,
            "author image url": authorImageUrl,
          })
              .then((value) => print("Post Created"))
              .catchError((error) => print("Failed to create Post: $error"));
        });

  }

  Future<void> update() async {

    await uploadImages(imageUint8Lists)
        .then((urls) {
      print("after upload images function is done, we create post doc with url list ready");
      print(urls.length);
      // imageUrls = urls;
      // the post might already have links if it's editing.
      for(var u in urls.keys.toList()){
        thumbnailAndImageUrls[u] = urls[u];
      }
      // thumbnailAndImageUrls = urls;
      print("${thumbnailAndImageUrls.length} and ${imageUint8Lists.length}");
      if(thumbnailAndImageUrls.length != imageUint8Lists.length) {
        UniversalFunctions.showToast("Image uploading failed", UniversalValues.toastMessageTypeWarningColor);
      }
      // url list is where the images are saved
      FirebaseFirestore.instance.collection('posts')
          .doc(postDocName)
          .update({
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
        "thumbnail and image urls": thumbnailAndImageUrls,
        "author image url": authorImageUrl,
      })
          .then((value) => print("Post Created"))
          .catchError((error) => print("Failed to create Post: $error"));
    });

  }

  void delete() {

    FirebaseFirestore.instance.collection('posts')
        .doc(postDocName)
        .delete()
        .then((value) {
          UniversalFunctions.showToast("Your post is deleted", UniversalValues.toastMessageTypeGoodColor);
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
    FirebaseFirestore.instance.collection('posts')
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
    print("authorImageUrl: " +authorImageUrl);

  }
}

