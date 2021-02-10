
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nice_button/nice_button.dart';
import 'package:qanda/models/UserInformation.dart';
import 'package:qanda/universals/UniversalFunctions.dart';
import 'package:qanda/universals/UniversalValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart' show kIsWeb;

class UserInfoFormWidget extends StatefulWidget{

  UserInfoFormWidget({Key key, this.userName, this.messageText, this.profileUrl}) : super(key: key);
  var userName;
  var messageText;
  var profileUrl;
  
  @override
  _UserInfoFormWidgetState createState() => _UserInfoFormWidgetState();
}

class _UserInfoFormWidgetState extends State<UserInfoFormWidget>{

  var boxConstraints = BoxConstraints(minWidth: 100, maxWidth: 250);
  var boxColor = Colors.white;
  List<String> sampleProfileImageUrls = [];
  List<dynamic> profileImageUrlOrUInt8List = new List<dynamic>();

  TextEditingController textEditingController = new TextEditingController();

  var pickImageOptionShow = false;

  File image;
  final picker = ImagePicker();

  var userName = "";

  Future getImageOnPhones(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        Uint8List uInt8list = image.readAsBytesSync();
        profileImageUrlOrUInt8List.clear();
        profileImageUrlOrUInt8List.add(uInt8list);
      } else {
        print('No image selected.');
      }
    });
  }


  void getSampleProfileImageUrls(BuildContext context) async {
    firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref("sample profile images").listAll();
    for(firebase_storage.Reference ref in result.items){
      var url = await ref.getDownloadURL();
      print(url);
      setState(() {
        sampleProfileImageUrls.add(url);
      });
    }
    print(sampleProfileImageUrls);
    print("end of getting sampleProfileImageUrls");
  }


  Future<void> getImageOnWeb() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['png', 'jpg', 'svg', 'jpeg']
    );

    if (result != null) {
      List<dynamic> imageUint8ListsTemp = result.files.map((file) => file.bytes).toList();
      setState(() {
        for (var i in imageUint8ListsTemp) {
          profileImageUrlOrUInt8List.clear();
          profileImageUrlOrUInt8List.add(i);
        }
      });
    } else {
      UniversalFunctions.showToast("You didn't pick any image", UniversalValues.toastMessageTypeWarningColor);
    }
  }

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    textEditingController.text = userName;
    profileImageUrlOrUInt8List.add(widget.profileUrl);
    getSampleProfileImageUrls(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 350),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                // color: Colors.redAccent,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    ListTile(
                      title: Text(
                        widget.messageText,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                      child: Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            border: Border.all(color: const Color(0x33A6A6A6)),
                            image: DecorationImage(
                                image: profileImageUrlOrUInt8List.length == 0 ?
                                AssetImage('assets/images/no_photo.png',)
                                    :
                                profileImageUrlOrUInt8List[0].runtimeType == String
                                    ?
                                NetworkImage(profileImageUrlOrUInt8List[0])
                                    :
                                MemoryImage(profileImageUrlOrUInt8List[0]),
                                fit: BoxFit.fill)
                        ),
                      ),
                    ),

                    Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        child:
                        pickImageOptionShow
                            ?
                        Container(
                          // color: Colors.grey[300],
                          child: Stack(
                            children: [

                              Positioned(
                                right: 0.0,
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      pickImageOptionShow = false;
                                    });
                                  },
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: CircleAvatar(
                                      radius: 14.0,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(Icons.close, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.blueAccent,),
                                      onPressed: () {
                                        getImageOnPhones(ImageSource.camera);
                                      }
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.insert_photo_sharp, color: Colors.blueAccent,),
                                      onPressed: () {
                                        getImageOnPhones(ImageSource.gallery);
                                      }
                                  )
                                ],
                              ),

                            ],
                          ),
                        )
                            :

                        GridView.count(
                          physics: ScrollPhysics(),
                          // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
                          shrinkWrap: true,
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: List.generate(sampleProfileImageUrls.length, (index) {
                            if(index == 0) {
                              return InkWell(
                                  onTap: () {

                                    if(kIsWeb) {
                                      getImageOnWeb();
                                    } else {
                                      setState(() {
                                        pickImageOptionShow = true;
                                      });
                                    }


                                  },
                                  child:  Container(
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[300]
                                    ),
                                    child: Icon(Icons.add_photo_alternate),
                                  )
                              );
                            } else {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      profileImageUrlOrUInt8List.clear();
                                      profileImageUrlOrUInt8List.add(sampleProfileImageUrls[index]);
                                    });
                                  },
                                  child: Container(
                                      width: 15.0,
                                      height: 15.0,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              fit: BoxFit.fill,
                                              image: new NetworkImage(
                                                  sampleProfileImageUrls[index]
                                              )
                                          )
                                      )
                                  )
                              );
                            }
                          }
                          ),
                        )
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // IconButton(icon: Icon(Icons.person), onPressed: null),
                          Container(
                            color: boxColor,
                            constraints: boxConstraints,
                            margin: EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: textEditingController,
                              onChanged: (value){
                                userName = value;
                                // print(userName);
                              },
                              decoration: InputDecoration(
                                hintText: "What do you want to be called?",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          // color: boxColor,
                          // constraints: boxConstraints,
                          height: 60,
                          child: NiceButton(
                            width: 250,
                            radius: 40,
                            padding: const EdgeInsets.all(15),
                            // icon: Icons.account_box,
                            gradientColors: [Color(0xff5b86e5), Color(0xff36d1dc)],
                            text: "Ok",
                            onPressed: () async {

                              print(userName);

                              if (userName == "") {
                                print("user name not set");
                                UniversalFunctions.showToast("Username not updated", UniversalValues.toastMessageTypeWarningColor);
                              } else {
                                UserInformation userInformation = new UserInformation(email: FirebaseAuth.instance.currentUser.email);
                                userInformation.name = userName;

                                if(profileImageUrlOrUInt8List.length != 0) { // if profile image is chosen
                                  if(profileImageUrlOrUInt8List.runtimeType == String) { // if profile image is link
                                    userInformation.profileImageUrl = profileImageUrlOrUInt8List[0];
                                    userInformation.update();
                                  } else { // if profile image is image
                                    userInformation.uploadImage(profileImageUrlOrUInt8List[0]); // update is already in upload image
                                  }
                                  UniversalFunctions.showToast("Profile photo updated", UniversalValues.toastMessageTypeGoodColor);

                                } else {
                                  UniversalFunctions.showToast("Profile photo not updated", UniversalValues.toastMessageTypeWarningColor);
                                  userInformation.update();
                                }

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("userName", userName);
                                UniversalFunctions.showToast("Username updated", UniversalValues.toastMessageTypeGoodColor);
                              }

                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        )
    );
  }
}