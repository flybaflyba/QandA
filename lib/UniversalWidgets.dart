


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/UniversalValues.dart';

class UniversalWidgets {

  static Widget titleWidget(String title) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
            )
        ),
      ],
    );
  }


  static Widget largeImagesPhotoView(BuildContext context, PageController pageController, List<dynamic> imageUrls) {

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Stack(
            children: [
              Container(
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageUrls[index]),
                        initialScale: PhotoViewComputedScale.contained * 0.8,
                        heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                      );
                    },
                    itemCount: imageUrls.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                        ),
                      ),
                    ),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    pageController: pageController,
                    onPageChanged: (i) {
                      print(i);

                    },
                  )
              ),

              Positioned(
                top: 10,
                left: 0.0,
                right: 0.0,
                child:   Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageUrls.map((url) {
                    int index = imageUrls.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: UniversalValues.largeImagesPhotoViewCurrentIndex == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),



            ],

          )
      );
    }

  }


}