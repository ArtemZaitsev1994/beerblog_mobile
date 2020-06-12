import 'dart:io';

import 'package:beerblog/common/utils.dart';
import 'package:beerblog/screens/admin/adminJson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AdminItemsListScreen extends StatefulWidget {
  final String itemType;
  const AdminItemsListScreen({Key key, this.itemType}) : super(key: key);
  @override
  _AdminItemsListScreenState createState() => _AdminItemsListScreenState();
}

class _AdminItemsListScreenState extends State<AdminItemsListScreen> {
// Общий класс для алкоголя, нужно переписать методы
//   _sendAlcoholItem
//   _firstScreen
//   _secondScreen
//   _drawNewAlcoholItemForm
  SortingBloc sorting = SortingBloc();
  bool needSort = true;
  var user;
  int page = 1;
  String query = '';
  List<String> sortItems = ["Новые", "Старые", "Лучшие", "Худшие"];
  String currentSort;

  String serverAnswerText = '';
  TextStyle serverAnswerStyle;
  Widget serverAnswer;

  SharedPreferences localStorage;
  String emptyString;
  String userName;

  // String barName;
  // String manufacturer;
  // double alcohol;
  // double fortress;
  // double ibu;
  // String review;
  // double rate = 50;
  // String others;
  File file;
  Map<String, dynamic> barItem = {
    'rate': 50.0,
    'country': 'Россия',
    'city': 'Екатеринбург',
  };

  List<Widget> screenNames = [Text('Просмотр'), Text('Добавить новое')];
  List<Widget> screens;

  @override
  void initState() {
    super.initState();
    sorting.changeSorting.add('Новые');
    serverAnswer = Text(serverAnswerText, style: serverAnswerStyle);
    emptyString = '';
    screenNames = [
      Tab(
          child: Align(
        alignment: Alignment.center,
        child: Text("Просмотр"),
      )),
      Tab(
          child: Align(
        alignment: Alignment.center,
        child: Text("Добавить новое"),
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _drawAppBar(),
      body: _firstScreen(),
      resizeToAvoidBottomInset: false,
    );
  }

  AppBar _drawAppBar() {
    return AppBar(
      title: Text(
        'BeerBlog',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      actions: <Widget>[
        DropdownButton<String>(
          value: currentSort,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.white),
          onChanged: (String newValue) {
            page = 1;
            sorting.changeSorting.add(newValue);
          },
          selectedItemBuilder: (BuildContext context) {
            return sortItems.map((String value) {
              return Center(
                  child: Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ));
            }).toList();
          },
          items: sortItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toString(),
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _firstScreen() {
    return StreamBuilder<String>(
        stream: sorting.changedSorting,
        builder: (BuildContext context, snap) {
          if (snap.hasData) {
            currentSort = snap.data;
            return FutureBuilder(
                future: getItemsList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // AdminItemsList itemsList = AdminItemsList.fromJson(
                    //     json.decode(utf8.decode(snapshot.data)));
                    var items = json.decode(utf8.decode(snapshot.data))[widget.itemType];
                    var p = Pagination.fromJson(json.decode(utf8.decode(snapshot.data))['pagination']);
                    AdminItemsList itemsList = AdminItemsList(items, p);
                    return Column(children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Container(
                              color: Colors.black,
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Поиск по названию:',
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  filled: true,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    query = value;
                                    page = 1;
                                  });
                                },
                              ))),
                      Expanded(
                        flex: 9,
                        child: ListView.builder(
                            itemCount: itemsList.items.length,
                            itemBuilder: (context, index) {
                              return Card(
                                  child: InkWell(
                                child: ListTile(
                                    title: Text('${itemsList.items[index]['name']}'),
                                    leading: Image.network(
                                        '${itemsList.items[index]['mini_avatar']}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.star, color: Colors.yellow),
                                        Text(
                                            itemsList.items[index]['rate'].toString())
                                      ],
                                    )),
                                onTap: () {
                                  Navigator.pushNamed(context, "/admin/item_card",
                                      arguments: {
                                        'id': itemsList.items[index]['_id'],
                                        'itemType': widget.itemType,
                                      }
                                    );
                                },
                              ));
                            }),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                              color: Colors.black,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      makePagination(itemsList.pagination))))
                    ]);
                  } else if (snapshot.hasError) {
                    return Text('Error');
                  }
                  return Center(child: CircularProgressIndicator());
                });
          } else if (snap.hasError) {
            return Text('Error');
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  getItemsList() async {
    var sortMap = {
      "Новые": "time_desc",
      "Старые": "time_asc",
      "Худшие": "rate_asc",
      "Лучшие": "rate_desc",
    };
    String _url = 'http://212.220.216.173:10501/${widget.itemType}/get_${widget.itemType}';
    print(_url);
    final response = await http.post(
        _url,
        body: json.encode(
            {'query': query, 'page': page, 'sorting': sortMap[currentSort]}));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    // throw Exception('Error: ${response.reasonPhrase}');
  }

  List<Widget> makePagination(Pagination pagination) {
    TextStyle prevStyle;
    TextStyle nextStyle;
    Color colorPrev;
    Color colorNext;
    var onPressedPrev;
    var onPressedNext;

    if (pagination.page > 1) {
      prevStyle = TextStyle(color: Colors.white);
      onPressedPrev = getPrevPage;
      colorPrev = Colors.white;
    } else {
      prevStyle = TextStyle(color: Colors.white24);
      onPressedPrev = null;
      colorPrev = Colors.white24;
    }

    if (pagination.hasNext) {
      nextStyle = TextStyle(color: Colors.white);
      onPressedNext = getNextPage;
      colorNext = Colors.white;
    } else {
      nextStyle = TextStyle(color: Colors.white24);
      onPressedNext = null;
      colorNext = Colors.white24;
    }

    return [
      OutlineButton(
        child: Row(children: <Widget>[
          Icon(Icons.chevron_left, color: colorPrev),
          Text('Предыдущая', style: prevStyle),
        ]),
        onPressed: onPressedPrev,
      ),
      VerticalDivider(
        color: Colors.white,
      ),
      Text(pagination.page.toString(), style: TextStyle(color: Colors.white)),
      VerticalDivider(
        color: Colors.white,
      ),
      OutlineButton(
        child: Row(children: <Widget>[
          Text('Следующая', style: nextStyle),
          Icon(Icons.chevron_right, color: colorNext)
        ]),
        onPressed: onPressedNext,
      ),
    ];
  }

  void getPrevPage() {
    setState(() {
      page -= 1;
    });
  }

  void getNextPage() {
    setState(() {
      page += 1;
    });
  }
}
