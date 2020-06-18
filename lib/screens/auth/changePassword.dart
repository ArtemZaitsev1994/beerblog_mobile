import 'dart:convert';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String answer = '';
  TextStyle answerStyle;

  String currentPassword;
  String newPass;
  String repeatedNewPass;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: MainAppBar(),
        body: _drawBody());
  }

  Widget _drawBody() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(children: <Widget>[
          TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Текущий пароль',
                fillColor: Colors.black54,
                focusColor: Colors.black,
              ),
              onChanged: (value) {
                currentPassword = value;
              }),
          SizedBox(height: 10),
          TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Новый пароль',
                fillColor: Colors.black54,
                focusColor: Colors.black,
              ),
              onChanged: (value) {
                newPass = value;
              }),
          SizedBox(height: 10),
          TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Повтори новый пароль',
                fillColor: Colors.black54,
                focusColor: Colors.black,
              ),
              onChanged: (value) {
                repeatedNewPass = value;
              }),
          SizedBox(height: 40),
          RaisedButton(
            child: Text('Сменить пароль'),
            onPressed: _changePassword,
          ),
          Text(
            answer,
            style: answerStyle,
          )
        ]));
  }

  bool comparePasswords() {
    return newPass == repeatedNewPass;
  }

  void _changePassword() async {
    if (!comparePasswords()) {
      setState(() {
        answer = 'Пароли не совпадают.';
        answerStyle = TextStyle(color: Colors.red);
      });
      return;
    }
    if (repeatedNewPass.length < 3) {
      setState(() {
        answer = 'Пароль должен быть длинее 3 символов.';
        answerStyle = TextStyle(color: Colors.red);
      });
      return;
    }

    final url = '$serverAPI/api/change_password';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    final response = await http.post(url,
        headers: {'Authorization': '$token'},
        body:
            json.encode({'new_psw': repeatedNewPass, 'psw': currentPassword}));

    if (response.statusCode == 200) {
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success']) {
        setState(() {
          answer = 'сменил';
          answerStyle = TextStyle(color: Colors.green);
        });
      } else {
      setState(() {
        answer = 'Неверный текущий пароль.';
        answerStyle = TextStyle(color: Colors.red);
      });
      }
    } else {
      throw Exception('Error!!!: ${response.reasonPhrase}');
    }
  }
}
