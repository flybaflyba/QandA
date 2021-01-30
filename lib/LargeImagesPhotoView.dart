

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:qanda/UniversalValues.dart';

class LargeImagesPhotoView extends StatefulWidget{

  LargeImagesPhotoView({Key key, this.pageController, this.imageUrls}) : super(key: key);

  PageController pageController;
  List<dynamic> imageUrls;

  @override
  _LargeImagesPhotoViewState createState() => _LargeImagesPhotoViewState();
}

class _LargeImagesPhotoViewState extends State<LargeImagesPhotoView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            constraints: BoxConstraints(minWidth: 150, maxWidth: 1000),
            child: Stack(
              children: [
                Container(
                    child: PhotoViewGallery.builder(
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(widget.imageUrls[index]),
                          initialScale: PhotoViewComputedScale.contained * 0.8,
                          heroAttributes: PhotoViewHeroAttributes(
                              tag: widget.imageUrls[index]),
                        );
                      },
                      itemCount: widget.imageUrls.length,
                      loadingBuilder: (context, event) {
                        return Center(
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes,
                            ),
                          ),
                        );
                      },
                      backgroundDecoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      pageController: widget.pageController,
                      onPageChanged: (i) {
                        print(i);
                        setState(() {
                          UniversalValues.currentViewingImageIndex = i;
                        });
                      },
                    )
                ),

                Positioned(
                  top: 10,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imageUrls.map((url) {
                      int index = widget.imageUrls.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UniversalValues.currentViewingImageIndex ==
                              index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              ],

            ),
          ),
        )

    );
  }
}
