

import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget{

  final String title;

  TitleWidget({
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
            )
        ),
      ],
    );
  }
}
