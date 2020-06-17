import 'dart:convert';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/auth/authJson.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../common/utils.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String login;
  String password;
  Widget success = Text('');
  bool needPopBack = false;

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;
    needPopBack = settings.arguments ?? needPopBack;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: MainAppBar(),
      body: FutureBuilder(
        future: _checkAuth(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['user'] != null) {
              return _drawUserData(snapshot.data['user']);
            } else {
              return _drawAuthorizatioin();
            }
          } else if (snapshot.hasError) {
            return Text('Error');
          }
          return Center(child: CircularProgressIndicator());
        }),
    );
  }

  Future _checkAuth() async {
    return await getCurrentUser();
  }

  Widget _drawUserData(user) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: <Widget>[
        Text(
          'Привет, ${user['name']}',
          style: TextStyle(fontSize: 23),
        ),
        SizedBox(
          height: 40,
        ),
        RaisedButton(
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: _logout,
          child: Text("Разлогиниться"),
        ),
        success,
        SizedBox(
          height: 30,
        ),
        Center(
          child: InkWell(
              child: Text(
                'Аккаунты раздаю я, и только.\nЯ здесь власть.',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    color: Colors.blue),
              ),
              onTap: () => launch('https://vk.com/artemleonzaitsev')),
        ),
      ]),
    ));
  }

  Widget _drawAuthorizatioin() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(children: <Widget>[
        Text(
          'Авторизация.',
          style: TextStyle(fontSize: 23),
        ),
        SizedBox(
          height: 40,
        ),
        TextField(
            maxLines: 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Логин',
              fillColor: Colors.black54,
              focusColor: Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                login = value;
              });
            }),
        SizedBox(
          height: 20,
        ),
        TextField(
            maxLines: 1,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Пароль',
              fillColor: Colors.black54,
              focusColor: Colors.black,
            ),
            onChanged: (value) {
              setState(() {
                password = value;
              });
            }),
        SizedBox(
          height: 30,
        ),
        RaisedButton(
          padding: const EdgeInsets.all(8.0),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: _auth,
          child: new Text("Авторизация"),
        ),
        success,
        SizedBox(
          height: 30,
        ),
        Center(
          child: new InkWell(
              child: new Text(
                'Аккаунты раздаю я, и только.\nЯ здесь власть.',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    color: Colors.blue),
              ),
              onTap: () => launch('https://vk.com/artemleonzaitsev')),
        ),
      ]),
    ));
  }

  void _logout() async {
    await LocalStorage.setStr('user', null);
    await LocalStorage.setStr('jwtToken', null);
    setState(() {
      success = Text('', style: TextStyle(color: Colors.green));
      if (needPopBack) {
        Navigator.pop(context);
      }
    });
  }

  void _auth() async {
    final String authServerLink = '$serverAuth/login';
    var data = {
      'login': login,
      'password': password,
      'service': 'beerblog',
      'section': 'beer'
    };

    final response = await http.post(authServerLink, body: json.encode(data));

    if (response.statusCode == 200) {
      AuthData authData =
          AuthData.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      if (authData.success) {
        await LocalStorage.setStr('jwtToken', authData.token);
        String userData =
            '${authData.user.login}|${authData.user.name}|${authData.user.sername}';
        await LocalStorage.setStr('user', userData);

        setState(() {
          success = Text('', style: TextStyle(color: Colors.green));
          if (needPopBack) {
            var user = {
              'login': authData.user.login,
              'name': authData.user.name,
              'sername': authData.user.sername,
            };
            Navigator.pop(context, user);
          }
        });
      } else {
        setState(() {
          success = Text('Неудача', style: TextStyle(color: Colors.red));
        });
      }
    }
  }
}
