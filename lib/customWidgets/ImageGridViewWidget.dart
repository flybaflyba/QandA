

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'file:///C:/Projects/QandA/lib/customWidgets/LargeImagesPhotoWidget.dart';
import 'file:///C:/Projects/QandA/lib/customWidgets/NetworkImageWidget.dart';
import 'file:///C:/Projects/QandA/lib/universals/UniversalValues.dart';

class ImageGridViewWidget extends StatelessWidget {

  Map<dynamic, dynamic> thumbnailAndImageUrls;
  BuildContext context;

  ImageGridViewWidget({
    @required this.thumbnailAndImageUrls,
    @required this.context,
  });


  @override
  Widget build(BuildContext context) {
    var urls = thumbnailAndImageUrls.keys.toList();

    if (urls.length == 0) {
      // no image
      return SizedBox(height: 0,);
    } else {
      int crossAxisCount = 3;
      var numOfImages = urls.length;
      // lots of code, but easy to understand
      if (numOfImages == 1) {
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
        physics: ScrollPhysics(),
        // fix scroll event conflict problem, without this line, when scroll on gridview, listview does not scroll
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(urls.length, (index) {
          return InkWell(
              onTap: () {
                print("tapped image index " + index.toString() + " with url " +
                    urls[index]);
                UniversalValues.currentViewingImageIndex =
                    index; // we need this so that indicator in large view is at the right position
                var pageController = PageController(initialPage: index);
                Future<void> future = showCupertinoModalBottomSheet(
                  // expand: false,
                  // bounce: true,
                    useRootNavigator: true,
                    context: context,
                    duration: Duration(milliseconds: 700),
                    builder: (context) =>
                        LargeImagesPhotoWidget(pageController: pageController,
                          imageUrls: thumbnailAndImageUrls.values.toList(),)
                );
                future.then((void value) {
                  print("bottom sheet closed");
                  UniversalValues.currentViewingImageIndex =
                  0; // try not to change it because we are not in show post page
                  print(UniversalValues.currentViewingImageIndex);
                });
              },
              child: Container(
                child: NetworkImageWidget(
                    url: urls[index]), // myNetworkImage(urls[index], null),
              )
          );
        }
        ),
      );
    }
  }
}

