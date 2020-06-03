import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildAboutDialog() {
    return new AlertDialog(
      title: const Text('About Pop up'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('hi'),
        ],
      ));
}