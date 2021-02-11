
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as imagePackage;

class UserInformation {
  var name = "";
  var email = "";
  var major = "";
  var profileImageUrl = "";

  UserInformation({
    var name,
    var email,
    var major,
    var profileImageUrl,
  }){
    if(name != null){ this.name = name; }
    if(email != null){ this.email = email; }
    if(major != null){ this.major = major; }
    if(profileImageUrl != null){ this.profileImageUrl= profileImageUrl; }
  }

  Future<void> get() async {

    print("getting user info from database");

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get();
    //     .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', documentSnapshot.data()["name"]);
        await prefs.setString('userEmail', documentSnapshot.data()["email"]);
        await prefs.setString('userMajor',  documentSnapshot.data()["major"]);
        await prefs.setString('profileImageUrl',  documentSnapshot.data()["profile image url"]);

        name = documentSnapshot.data()["name"];
        email = documentSnapshot.data()["email"];
        major = documentSnapshot.data()["major"];
        profileImageUrl = documentSnapshot.data()["profile image url"];

        print(name);
        print(email);
        print(profileImageUrl);

      } else {
        print('User document does not exist on the database');
      }
    // });

  }

  Future<void> clearLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', "");
    await prefs.setString('userEmail', "");
    await prefs.setString('userMajor',  "");
    await prefs.setString('profileImageUrl',  "");
    name = "";
    email = "";
    major = "";
    profileImageUrl = "";

  }

  // useless
  // void setUserInformationWithDocumentSnapshot(DocumentSnapshot userInformationDocumentSnapshot) {
  //   name = userInformationDocumentSnapshot["name"];
  //   email = userInformationDocumentSnapshot["email"];
  //   major= userInformationDocumentSnapshot["major"];
  // }

  void create() {
    FirebaseFirestore.instance.collection('users')
        .doc(email) // user information document name is user's email
        .set({
      "name": name,
      'email': email,
      "major": major,
      "profile image url": profileImageUrl,
    })
        .then((value) async {
      print("User Information Created");
    })
        .catchError((error) => print("Failed to create user Information: $error"));
  }


  Future<void> uploadImage(var imageUint8List) async {

    if(imageUint8List.runtimeType == String) {
      profileImageUrl = imageUint8List;
    } else {
      Reference ref = FirebaseStorage.instance.ref('profile images/$email');
      imagePackage.Image image = imagePackage.decodeImage(imageUint8List); // TODO this process of is taking long time only ON WEB
      imagePackage.Image thumbnail = imagePackage.copyResize(image, width: 200);
      Uint8List thumbnailUint8list = imagePackage.encodePng(thumbnail);
      SettableMetadata settableMetadata = SettableMetadata(contentType: 'image');
      try {
        await ref.putData(thumbnailUint8list, settableMetadata)
            .timeout((Duration(seconds: 10)), onTimeout: () {
          UniversalFunctions.showToast("Your internet is too slow", UniversalValues.toastMessageTypeWarningColor);
          return null;
        })
            .catchError((e){
          print("image upload failed due to error $e");
        });
        String imageUrl = await ref.getDownloadURL();
        profileImageUrl = imageUrl;

      } on FirebaseException catch (e) {
        print("image upload failed due to error $e");
      }
    }
    update();

  }

  void update() {
    FirebaseFirestore.instance.collection('users')
        .doc(email) // user information document name is user's email
        .update({
      "name": name,
      'email': email,
      "major": major,
      "profile image url": profileImageUrl,
    })
        .then((value) async {
      print("User Information Updated");
    })
        .catchError((error) => print("Failed to update user Information: $error"));
  }

  List printOut() {
    return [
      email,
      name,
      major,
      profileImageUrl,
    ];
  }
}

