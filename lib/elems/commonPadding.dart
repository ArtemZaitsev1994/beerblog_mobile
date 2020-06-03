import 'package:flutter/material.dart';


Container commonPadding(elem) {
  return Container(
    child: Stack(
      children: <Widget>[
        Container(
          color: Colors.black,
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          // padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: mainDecoration(),
          height: double.infinity,
          width: double.infinity,
          child: elem,
        )
      ]
    )
  );
}

BoxDecoration mainDecoration() {
  return BoxDecoration(
    color: Colors.white
    
  );
}
