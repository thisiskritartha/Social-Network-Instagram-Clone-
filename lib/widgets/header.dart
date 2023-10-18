import 'package:flutter/material.dart';

AppBar header(context,
    {bool isTitle = false, String? title, bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isTitle ? 'FlutterChat' : title!,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isTitle ? "LuxuriousScript" : "",
        fontSize: isTitle ? 50.0 : 22.0,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
        letterSpacing: isTitle ? 1.4 : 1,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.secondary,
  );
}
