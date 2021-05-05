import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar header({bool isAppTitle = false,String text,bool backDirection = false}) {
  return AppBar(
    backgroundColor: Colors.teal,
    automaticallyImplyLeading: backDirection, // remove back button on appbar
    title: Text(
      isAppTitle ? 'FlutterShare' : text,
      style: TextStyle(
          fontSize: isAppTitle ? 50.0 : 22.0,
          fontFamily: isAppTitle ? 'Signatra' : ""
      ),
      overflow: TextOverflow.ellipsis,
    ),

    centerTitle: true,
  );
}
