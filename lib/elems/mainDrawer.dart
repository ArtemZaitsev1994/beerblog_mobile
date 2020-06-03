 import 'package:flutter/material.dart';


  var categories = [
    ['01: Домашная страница', '/'],
    ['02: Пиво', '/beer'],
    ['03: Вино (пока нет)', 'link'],
    ['04-08: чо-нить (пока нет)', 'link'],
    ['09: Авторизация', '/auth'],
  ];

class MainDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        // padding: EdgeInsets.zero,
        // padding: const EdgeInsets.all(15),
        children: 
          getDrawerContent(context)
      ),
    );
  }
}

List<Widget> getMenuItems(BuildContext context) {
  var result = <Widget>[];
  String currentUrl = ModalRoute.of(context).settings.name;

  for (var i = 0; i <= categories.length - 1; i++) {
    result.add(
      ListTile(
        title: Text(categories[i][0]),
        onTap: () {
          if (currentUrl == '/') {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, categories[i][1]);
          } else {
            Navigator.pushReplacementNamed(context, categories[i][1]);
          }
        }
      )
    );
    if(i < categories.length - 1) {
      result.add(Divider());
    }
  }

  return result;
}

Container getHeader() {
  return Container(
    height: 50,
    child: DrawerHeader(
      child: Text('Навигационное меню', style: TextStyle(color: Colors.white)),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    )
  );
}

List getDrawerContent(BuildContext context) {
  var result = <Widget>[getHeader()];
  result.addAll(getMenuItems(context));
  return result;
}