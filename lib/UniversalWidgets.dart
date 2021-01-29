


import 'package:flutter/cupertino.dart';

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


}