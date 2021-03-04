

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NetworkImageWidget extends StatelessWidget{

  final String url;
  final double width;

  NetworkImageWidget({
    @required this.url,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: width,
        filterQuality: FilterQuality.high,
        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) return child;
          return SpinKitRipple(
            color: Colors.blue,
            size: 50.0,
          );
        },
        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
          print("error loading network image");
          print(exception);
          print(stackTrace);
          return Icon(Icons.image_not_supported);
        },
      ),
    );
  }
}
