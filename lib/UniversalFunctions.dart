
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qanda/UniversalValues.dart';

class UniversalFunctions{

  static void showToast(String msg, Color toastMessageType) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: toastMessageType,
        webBgColor: toastMessageType == UniversalValues.toastMessageTypeWarningColor ? "linear-gradient(to right, #cc00ff, #ff0000)" : "	linear-gradient(to right, #00b09b, #96c93d)",
        webPosition: "center",
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}