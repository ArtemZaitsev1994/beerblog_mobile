import 'dart:convert';

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
              // AdminPanel typesList =
              //     AdminPanel.fromJson(json.decode(utf8.decode(snapshot.data)));
              AdminPanel typesList =
                  AdminPanel(items: [
                    Item(itemType: 'beer', notConfirmed: 2),
                    Item(itemType: 'wine', notConfirmed: 0),
                    Item(itemType: 'bar', notConfirmed: 2)
                  ]);
              
              return Column(children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemCount: typesList.items.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: InkWell(
                          child: ListTile(
                              title: Text('${typesList.items[index].itemType}'),
                              // leading: Image.network(
                              //     '${barsList.bar[index].mini_avatar}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
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
    String _url = 'http://212.220.216.173:10501/admin/admin_panel_list';

    final response = await http.post(_url);
    return response.bodyBytes;
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

}
