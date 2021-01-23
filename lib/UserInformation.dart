
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void setUserInformationWithDocumentSnapshot(DocumentSnapshot userInformationDocumentSnapshot) {
    name = userInformationDocumentSnapshot["name"];
    email = userInformationDocumentSnapshot["email"];
    major= userInformationDocumentSnapshot["major"];
  }

  void create() {
    FirebaseFirestore.instance.collection('users')
        .doc(email) // user information document name is user's email
        .set({
      "name": name,
      'email': email,
      "major": major,
    })
        .then((value) => print("User Information Created"))
        .catchError((error) => print("Failed to create user Information: $error"));
  }

  List printOut() {
    return [
      email,
      name,
      major,
    ];
  }
}

