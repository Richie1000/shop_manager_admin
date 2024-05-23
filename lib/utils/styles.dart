import 'package:flutter/material.dart';

Color primary  = const Color(0xff687daf);

class Styles{
 static Color primaryColor = primary;
 static Color bgColor = const Color(0xffeeedf2);
 static Color textColor =const Color(0xff3b3b3b);
 static Color orangeColor = const Color(0xfff37b67);
 static Color kakiColor = const Color(0xFFd2bdb6);
 

  static TextStyle textStyle = TextStyle(
    fontSize:16, color: textColor, fontWeight: FontWeight.w500
  );
  static TextStyle headLine1 = TextStyle(
    fontSize:26, color: textColor, fontWeight: FontWeight.bold
  );
  static TextStyle headline2 = TextStyle(
    fontSize:21, color: textColor, fontWeight: FontWeight.bold
  );
  static TextStyle headline3 = TextStyle(
    fontSize:17, color: Colors.grey.shade500, fontWeight: FontWeight.w500
  );
  static TextStyle headline4 = TextStyle(
    fontSize:14, color: Colors.grey.shade500, fontWeight: FontWeight.w500
  );

}