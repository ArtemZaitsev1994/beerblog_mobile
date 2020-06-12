import 'dart:convert';

import 'package:beerblog/common/jsonModels.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/comments.dart';
import 'package:beerblog/screens/bar/barJson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../common/utils.dart';

class AdminItemCard extends StatefulWidget {
  @override
  _AdminItemCardState createState() => _AdminItemCardState();
}

class _AdminItemCardState extends State<AdminItemCard> {
  String itemId;
  String itemType;
  var user;
  String comment;
  String barId;
  List comments;
  var rating;
  var yourRate;
  final commentController = TextEditingController();

  clearTextInput() => commentController.clear();

  @override
  void initState() {
    super.initState();
    comments = [];
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
            future: _getBarItem(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _drawItem(snapshot.data);
              } else if (snapshot.hasError) {
                return Text('Error');
              }
              return Center(child: CircularProgressIndicator());
            })
      );
  }

  Future<Map> _getBarItem() async {
    final url = 'http://212.220.216.173:10501/$itemType/get_${itemType}_item';
    final response = await http.post(url, body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }


  Widget _drawItem(Map item) {
    print(item[itemType].keys.toList());
    List fields = item[itemType].keys.toList();
    return 
    Column(
      children: <Widget>[
        Expanded( child: 
        ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(children: <Widget>[

                Text('${fields[index]}'),
                TextField(
                    controller: TextEditingController(text: '${item[itemType][fields[index]]}'),
                  ),
              ],) 
            );
          })),Row(children: <Widget>[
          
        Expanded(
          child:RaisedButton(child: Text('Сохранить'))),
          
        Expanded(
          child: RaisedButton(
            child: item[itemType]['not_confirmed'] == true
              ? Text('Автивировать', style: TextStyle(color: Colors.green))
              : Text('Деактивировать', style: TextStyle(color: Colors.red)),
            onPressed: changeItemStatus,
          )
        ),
         
        Expanded(
          child: RaisedButton(child: Text('Удалить'))),
        ]),
      ]
    );
  }

  void changeItemStatus() async {
    final url = 'http://212.220.216.173:10501/$itemType/change_state_${itemType}';
    final response = await http.post(url, body: json.encode({'id': itemId}));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }
}
