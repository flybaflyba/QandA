
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Post {
  var title = "";
  var content = "";
  var author = "";
  var createdTime = "";
  List<Asset> images = [];

  List<String> imageUrls = [];

  Post({
    var title,
    var content,
    var author,
    var createdTime,
    var images,
  }){
    if(title != null){ this.title = title; }
    if(content != null){ this.content = content; }
    if(author != null){ this.author = author; }
    if(createdTime != null){ this.createdTime = createdTime; }
    if(images != null){ this.images = images; }
  }

  void setPostWithDocumentSnapshot(DocumentSnapshot postDocumentSnapshot) {
    title = postDocumentSnapshot["title"];
    content = postDocumentSnapshot["content"];
    author = postDocumentSnapshot["author"];
    createdTime = postDocumentSnapshot["created time"];
    imageUrls = postDocumentSnapshot["image urls"];
  }

  // upload images, and get their urls to store in the post doc
  Future<void> uploadImages(List<Asset> imageAssets) async {
    for (Asset imageAsset in imageAssets) {
      final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);

      File imageFile = File(filePath);
      if (imageFile.existsSync()) {
        print(imageAsset.toString() + " --- converted image asset to file --- " + imageFile.toString());
      }
      String name = createdTime + " - " + imageAssets.indexOf(imageAsset).toString();
      StorageReference reference =
      FirebaseStorage.instance.ref().child('post Images').child(createdTime).child(name);
      StorageUploadTask uploadTask = reference.putFile(imageFile);
      StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      String url = await downloadUrl.ref.getDownloadURL();
      imageUrls.add(url);
      print(imageUrls.length);
    }
    print("end of the uploading images");
  }


  Future<void> create() async {

    await uploadImages(images)
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
      images,
      imageUrls,
    ]);
  }
}

