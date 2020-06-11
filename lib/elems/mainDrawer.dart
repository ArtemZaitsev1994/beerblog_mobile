import 'package:beerblog/common/utils.dart';
import 'package:flutter/material.dart';

var categories = [
  ['01: Домашная страница', '/'],
  ['02: Пиво', '/beer'],
  ['03: Вино', '/wine'],
  ['04: Бары', '/bar'],
  ['05: Авторизация', '/auth'],
];

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: getDrawerContent(context),
    );
  }
}

Widget _adminButton() {
  return FutureBuilder(
      future: getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['user'] == null || snapshot.data['user']['login'] != 'admin') {
            return SizedBox.shrink();
          } else {
          return Column(
            children: [
            Divider(),
            ListTile(
            title: Text('06: Админка'),
            onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
            })]);
          }
        } else if (snapshot.hasError) {
          return Text('Error');
        }
        return Center(child: CircularProgressIndicator());
      });
}

List<Widget> getMenuItems(BuildContext context) {
  var result = <Widget>[];
  String currentUrl = ModalRoute.of(context).settings.name;

  for (var i = 0; i <= categories.length - 1; i++) {
    result.add(ListTile(
        title: Text(categories[i][0]),
        onTap: () {
          if (currentUrl == '/') {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, categories[i][1]);
          } else {
            Navigator.pushReplacementNamed(context, categories[i][1]);
          }
        }));
    if (i < categories.length - 1) {
      result.add(Divider());
    }
  }
  
  result.add(_adminButton());

  return result;
}

Container getHeader(context) {
  return Container(
    height: 75,
    
    width: MediaQuery.of(context).size.width * 0.85,
    child: DrawerHeader(
      child: Text('Навигационное меню', style: TextStyle(color: Colors.white)),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    ),
  );
}

Widget getDrawerContent(BuildContext context) {
  Column result = Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: <Widget>[
      getHeader(context),
      Expanded(
        child: ListView(children: getMenuItems(context)),
      ),
      Container(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(children: [
            Divider(),
            ListTile(
                title: Row(children: [
                  Text('Инструкция (для бумеров) '),
                  Icon(Icons.info_outline)
                ]),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/info');
                })
          ]),
        ),
      )
    ],
  );
  return result;
}


