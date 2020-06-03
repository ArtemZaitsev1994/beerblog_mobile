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
      // leading: IconButton(icon: Icon(Icons.menu, color: Colors.white,), onPressed: null),
      // iconTheme: IconThemeData(color: Colors.red),
      // brightness: Brightness.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}




class AppBarWithSorting extends StatelessWidget with PreferredSizeWidget {

  @override
  Widget build(BuildContext context){
    return AppBar(
      title: Text(
        'BeerBlog',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      actions: this.getSortSettings(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  List<Widget> getSortSettings() {
    return [MyStatefulWidget()];
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.white),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}