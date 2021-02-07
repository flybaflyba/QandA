


import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/LargeImagesPhotoView.dart';
import 'package:qanda/NetworkImageWidget.dart';
import 'package:qanda/Post.dart';
import 'package:qanda/ShowPostPage.dart';
import 'package:qanda/SignInUpPage.dart';
import 'package:qanda/UniversalFunctions.dart';
import 'package:qanda/UniversalValues.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UniversalWidgets {

  // static Widget titleWidget(String title) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 20,),
  //       Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Center(
  //             child: Text(
  //               title,
  //               style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
  //             ),
  //           )
  //       ),
  //     ],
  //   );
  // }



  static Widget gridView(Map<dynamic, dynamic> thumbnailAndImageUrls, BuildContext context) {

    var urls = thumbnailAndImageUrls.keys.toList();

    if(urls.length == 0) {
      // no image
      return SizedBox(height: 0,);
    } else {
      int crossAxisCount = 3;
      var numOfImages = urls.length;
      // lots of code, but easy to understand
      if(numOfImages == 1) {
        crossAxisCount = 1;
      } else if (numOfImages == 2) {
        crossAxisCount = 2;
      } else if (numOfImages == 3) {
        crossAxisCount = 3;
      } else if (numOfImages == 4) {
        crossAxisCount = 2;
      } else if (numOfImages == 5) {
        crossAxisCount = 3;
      } else if (numOfImages == 6) {
        crossAxisCount = 3;
      } else if (numOfImages == 7) {
        crossAxisCount = 3;
      } else if (numOfImages == 8) {
        crossAxisCount = 3;
      } else if (numOfImages == 9) {
        crossAxisCount = 3;
      }

      return GridView.count(
        physics: ScrollPhysics(), // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(urls.length, (index) {
          return InkWell(
            onTap: () {
              print("tapped image index " + index.toString() + " with url " + urls[index]);
              UniversalValues.currentViewingImageIndex = index; // we need this so that indicator in large view is at the right position
              var pageController = PageController(initialPage: index);
              Future<void> future = showCupertinoModalBottomSheet(
                // expand: false,
                // bounce: true,
                  useRootNavigator: true,
                  context: context,
                  duration: Duration(milliseconds: 700),
                  builder: (context) =>
                      LargeImagesPhotoView(pageController: pageController, imageUrls: thumbnailAndImageUrls.values.toList(),)
              );
              future.then((void value) {
                print("bottom sheet closed");
                UniversalValues.currentViewingImageIndex = 0; // try not to change it because we are not in show post page
                print(UniversalValues.currentViewingImageIndex);
              });

            },
            child: Container(
              child: NetworkImageWidget(url: urls[index]), // myNetworkImage(urls[index], null),
            )
          );
        }
        ),
      );
    }


  }



}