import 'dart:io';

import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/bar/barJson.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminItemsList extends StatefulWidget {
  final String itemType;
  const AdminItemsList({Key key, this.itemType}) : super(key: key);
  @override
  _AdminItemsListState createState() => _AdminItemsListState();
}

class _AdminItemsListState extends State<AdminItemsList> {
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
  final urlListItems = 'http://212.220.216.173:10501/bar/get_bar';
  List<String> sortItems = ["Новые", "Старые", "Лучшие", "Худшие"];
  String currentSort = 'Новые';
  
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
  TabController _tabController;

  List<Widget> screenNames = [Text('Просмотр'), Text('Добавить новое')];
  List<Widget> screens;

  @override
  void initState() {
    super.initState();
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
      body: _firstScreenFuture(),
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
              StreamBuilder<String>(
                  stream: sorting.changedSorting,
                  builder: (context, snapshot) {
                    currentSort = snapshot.data;
                    return DropdownButton<String>(
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
                      items: sortItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                    );
                  })
            ],
    );
  }

  Widget _firstScreenFuture() {
    return FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data['user'];
            return _firstScreen();
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _firstScreen() {
    return StreamBuilder<String>(
        stream: sorting.changedSorting,
        builder: (BuildContext context, snap) {
          return FutureBuilder(
              future: getItemsList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  BarData barsList =
                      BarData.fromJson(json.decode(utf8.decode(snapshot.data)));
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
                            },))),
                    Expanded(
                      flex: 9,
                      child: ListView.builder(
                          itemCount: barsList.bar.length,
                          itemBuilder: (context, index) {
                            return Card(
                                child: InkWell(
                              child: ListTile(
                                  title: Text('${barsList.bar[index].name}'),
                                  leading: Image.network(
                                      '${barsList.bar[index].mini_avatar}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.star, color: Colors.yellow),
                                      Text(barsList.bar[index].rate.toString())
                                    ],
                                  )),
                              onTap: () {
                                Navigator.pushNamed(context, "/bar_item",
                                    arguments: barsList.bar[index].barId);
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
                                children: makePagination(barsList.pagination))))
                  ]);
                } else if (snapshot.hasError) {
                  return Text('Error');
                }
                return Center(child: CircularProgressIndicator());
              });
        });
  }

  getItemsList() async {
    var sortMap = {
      "Новые": "time_desc",
      "Старые": "time_asc",
      "Худшие": "rate_asc",
      "Лучшие": "rate_desc",
    };
    print(page);
    print(sortMap[currentSort]);
    print(query);
    final response = await http.post(urlListItems,
        body: json.encode({'query': query, 'page': page, 'sorting': sortMap[currentSort]}));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Error: ${response.reasonPhrase}');
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
