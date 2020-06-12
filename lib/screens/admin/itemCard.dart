import 'dart:convert';

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
    final url = 'http://212.220.216.173:10501/$itemType/get_${itemType}_item';
    final response = await http.post(url, body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

  Widget _drawItem(Map _item) {
    item = _item;
    not_confirmed = item[itemType]['not_confirmed'];
    List fields = item[itemType].keys.toList();
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
                      controller: TextEditingController(
                          text: '${item[itemType][fields[index]]}'),
                    ),
                  ],
                ));
              })),
      Text(serverAnswer, style: serverAnswerStyle,),
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
          child: Text('Удалить'),
          onPressed: _showDialog,
        )),
      ]),
    ]);
  }

  void changeItemStatus() async {
    setState(() {
      serverAnswer = 'Успешно изменено';
      serverAnswerStyle = TextStyle(color: Colors.green, fontSize: 18); 
    });
    return; 
    final url =
        'http://212.220.216.173:10501/admin/$itemType/change_item_state';
    final response = await http.post(url, body: json.encode({'id': itemId, 'not_confirmed': !item['not_confirmed']}));

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
    }
    throw Exception('Error: ${response.reasonPhrase}');
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
                  child: const Text('Нет', style: TextStyle(fontSize: 15, color: Colors.black)),
                ),
              ],
            ),
          )
        );
      },
    );
  }

  void deleteItem() async {
    setState(() {
      serverAnswer = 'Успешно удалено';
      serverAnswerStyle = TextStyle(color: Colors.green, fontSize: 18); 
    });
    return; 
    final url =
        'http://212.220.216.173:10501/admin/$itemType/delete_item';
    final response = await http.post(url, body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['success']) {
        setState(() {
          serverAnswer = 'Успешно удалено';
          serverAnswerStyle = TextStyle(color: Colors.green, fontSize: 18);
          Navigator.pop(context);
        });
      } else {
        setState(() {
          serverAnswer = jsonResponse['message'];
          serverAnswerStyle = TextStyle(color: Colors.red, fontSize: 18); 
        });
      }
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }
}
