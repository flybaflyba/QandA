
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInformation {
  var name = "";
  var email = "";
  var major = "";

  UserInformation({
    var name,
    var email,
    var major,
  }){
    if(name != null){ this.name = name; }
    if(email != null){ this.email = email; }
    if(major != null){ this.major = major; }
  }

  Future<void> get() async {

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
      } else {
        print('User document does not exist on the database');
      }
    // });

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
    })
        .then((value) async {
      print("User Information Created");
    })
        .catchError((error) => print("Failed to create user Information: $error"));
  }

  void update() {
    FirebaseFirestore.instance.collection('users')
        .doc(email) // user information document name is user's email
        .update({
      "name": name,
      'email': email,
      "major": major,
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
    ];
  }
}

