
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversalValues {
  static Color primaryColor = Colors.blue;
  static Color buttonColor = Colors.pink;

  static Color toastMessageTypeGoodColor = Colors.blue;
  static Color toastMessageTypeWarningColor = Colors.red;

  static var courses = [
    "CIS101","CIS202","CIS205","CIS206",
    "CS203","CS210","CS301","CS490R",
    "IT224","IT240","IT280","IT320","IT390R","IT420","IT480",
    "IS350",
    "MATH107","MATH110","MATH111","MATH119","MATH121","MATH212","MATH213","MATH301","MATH421",
    "PHYS115","PHYS115L","PHYS121","PHYS121L",
    "FILM102", "FILM218", "FILM318", "FILM300", "FILM365R",
    "ENTR180", "ENTR283", "ENTR275", "ENTR285", "ENTR373", "ENTR380", "ENTR383", "ENTR375R", "ENTR390R", "ENTR401R", "ENTR483", "ENTR485", "ENTR499"
  ];

  static var largeImagesPhotoViewCurrentIndex = 0;
}