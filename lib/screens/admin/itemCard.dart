import 'dart:convert';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminItemCard extends StatefulWidget {
  @override
  _AdminItemCardState createState() => _AdminItemCardState();
}

class _AdminItemCardState extends State<AdminItemCard> {
  String itemId;
  String itemType;
  String serverAnswer;
  TextStyle serverAnswerStyle;
  var user;
  var rating;
  var yourRate;
  bool not_confirmed;

  Map item;

  @override
  void initState() {
    super.initState();
    serverAnswer = '';
  }

  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context).settings;

    Map arguments = settings.arguments;
    itemId = arguments['id'];
    itemType = arguments['itemType'];
    return Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: MainAppBar(),
        body: FutureBuilder<Map>(
            future: _getAdminItem(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _drawItem(snapshot.data);
              } else if (snapshot.hasError) {
                return Text('Error');
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Future<Map> _getAdminItem() async {
    final url = '$serverAPI/admin/$itemType/get_item';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    final response = await http.post(url,
        headers: {'Authorization': '$token'}, body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

  Widget _drawItem(Map _item) {
    item = _item;
    not_confirmed = item['not_confirmed'];
    List fields = item.keys.toList();
    return Column(children: <Widget>[
      Expanded(
          child: ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                if (fields[index] == 'not_confirmed') {
                  return SizedBox.shrink();
                }
                return Card(
                    child: Column(
                  children: <Widget>[
                    Text('${fields[index]}'),
                    TextField(
                      controller:
                          TextEditingController(text: '${item[fields[index]]}'),
                    ),
                  ],
                ));
              })),
      Text(
        serverAnswer,
        style: serverAnswerStyle,
      ),
      Row(children: <Widget>[
        Expanded(
            child: RaisedButton(
          child: Text('Сохранить'),
          onPressed: null,
        )),
        Expanded(
            child: RaisedButton(
          child: not_confirmed == true
              ? Text('Автивировать', style: TextStyle(color: Colors.green))
              : Text('Деактивировать', style: TextStyle(color: Colors.red)),
          onPressed: changeItemStatus,
        )),
        Expanded(
            child: RaisedButton(
          child: Text('Удалить', style: TextStyle(color: Colors.red)),
          onPressed: _showDialog,
        )),
      ]),
    ]);
  }

  void changeItemStatus() async {
    final url =
        '$serverAPI/admin/$itemType/change_item_state';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    not_confirmed = item['not_confirmed'] == null ? true : false;
    final response = await http.post(url,
        headers: {'Authorization': '$token'},
        body: json.encode({'id': itemId, 'not_confirmed': not_confirmed}));
    if (response.statusCode == 200) {
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success']) {
        setState(() {
          serverAnswer = 'Успешно изменено';
          serverAnswerStyle = TextStyle(color: Colors.green, fontSize: 18);
        });
      } else {
        setState(() {
          serverAnswer = jsonResponse['message'];
          serverAnswerStyle = TextStyle(color: Colors.red, fontSize: 18);
        });
      }
    } else {
      throw Exception('Error!!!: ${response.reasonPhrase}');
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: Text("Точно удалить запись?"),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteItem();
                    },
                    child: const Text('Да', style: TextStyle(fontSize: 15)),
                  ),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Нет',
                        style: TextStyle(fontSize: 15, color: Colors.black)),
                  ),
                ],
              ),
            ));
      },
    );
  }

  void deleteItem() async {
    final url = '$serverAPI/admin/$itemType/delete_item';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    final response = await http.post(url,
        headers: {'Authorization': '$token'},
        body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success']) {
        Navigator.pushReplacementNamed(context, '/admin/$itemType');
      } else {
        setState(() {
          serverAnswer = jsonResponse['message'];
          serverAnswerStyle = TextStyle(color: Colors.red, fontSize: 18);
        });
      }
    } else {
      throw Exception('Error!!!: ${response.reasonPhrase}');
    }
  }
}
