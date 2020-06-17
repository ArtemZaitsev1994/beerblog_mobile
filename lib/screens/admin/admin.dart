import 'dart:convert';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/admin/adminJson.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key key}) : super(key: key);
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}


class _AdminPanelScreenState extends State<AdminPanelScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: MainAppBar(),
      body: _drawAdminScrollView(context),
    );
  }

  Widget _drawAdminScrollView(BuildContext context) {
    return FutureBuilder(
          future: _getItemsTypesList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              AdminPanel typesList =
                  AdminPanel.fromJson(json.decode(utf8.decode(snapshot.data)));
              
              return Column(children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: typesList.items.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: InkWell(
                          child: ListTile(
                              title: Text('${typesList.items[index].itemType}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('всего: ${typesList.items[index].total}'),
                                  Icon(
                                    Icons.publish,
                                    color: 
                                      typesList.items[index].notConfirmed > 0
                                      ? Colors.green
                                      : Colors.grey
                                  ),
                                  Text(typesList.items[index].notConfirmed.toString())
                                ],
                              )),
                          onTap: () {
                            Navigator.pushNamed(context, "/admin/${typesList.items[index].itemType}");
                          },
                        ));
                      }),
                )
              ]);
            } else if (snapshot.hasError) {
              return Text('Error');
            }
            return Center(child: CircularProgressIndicator());
          });
    }
  
  Future _getItemsTypesList() async {
    String _url = '$serverAPI/admin/admin_panel_list';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');

    final response = await http.post(_url,
        headers: {'Authorization': '$token'});

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

}
