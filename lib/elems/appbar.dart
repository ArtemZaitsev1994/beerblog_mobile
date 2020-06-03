import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget with PreferredSizeWidget {

  @override
  Widget build(BuildContext context){
    return AppBar(
      title: Text(
        'BeerBlog',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
