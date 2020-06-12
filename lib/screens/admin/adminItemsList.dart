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
  bool needSort = true;
  var user;
  int page = 1;
  String query = '';
  final queryController = TextEditingController();

  SortingBloc sorting = SortingBloc();
  List<String> sortItems = ["Новые", "Старые", "Лучшие", "Худшие"];
  String currentSort;
  SortingConfirmedBloc sortingConfStream = SortingConfirmedBloc();
  List<String> confSortingFields = ["Подтвержденные", "Новые", "Все"];
  String confSorting;

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
      body: screen(),
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
        IconButton(icon: Icon(Icons.settings), onPressed: _showDialog)
      ],
    );
  }

  void _showDialog() {
    String newSorting = currentSort;
    String newConfSorting = confSorting;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Сортировка"),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  DropdownButton<String>(
                    value: newSorting,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    onChanged: (String newValue) {
                      setState(() {
                        newSorting = newValue;
                      });
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return sortItems.map((String value) {
                        return Center(
                            child: Text(
                          value,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ));
                      }).toList();
                    },
                    items:
                        sortItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: newConfSorting,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    onChanged: (String newValue) {
                      setState(() {
                        newConfSorting = newValue;
                      });
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return confSortingFields.map((String value) {
                        return Center(
                            child: Text(
                          value,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ));
                      }).toList();
                    },
                    items: confSortingFields
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if ((newConfSorting != null &&
                          newConfSorting != confSorting) &&
                      (newSorting != null && newSorting != currentSort)) {
                    setState(() {
                      page = 1;
                      sorting.changeSorting.add(newSorting);
                      sortingConfStream.changeSorting.add(newConfSorting);
                    });
                  } else if (newConfSorting != null &&
                      newConfSorting != confSorting) {
                    setState(() {
                      page = 1;
                      sortingConfStream.changeSorting.add(newConfSorting);
                    });
                  } else if (newSorting != null && newSorting != currentSort) {
                    setState(() {
                      page = 1;
                      sorting.changeSorting.add(newSorting);
                    });
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget screen() {
    return StreamBuilder<String>(
        stream: sorting.changedSorting,
        builder: (BuildContext context, snap) {
          if (snap.hasData) {
            currentSort = snap.data;

            return StreamBuilder<String>(
                stream: sortingConfStream.changedSorting,
                builder: (BuildContext context, snap2) {
                  if (snap2.hasData) {
                    confSorting = snap2.data;
                    return FutureBuilder(
                        future: getItemsList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // AdminItemsList itemsList = AdminItemsList.fromJson(
                            //     json.decode(utf8.decode(snapshot.data)));
                            var items = json.decode(
                                utf8.decode(snapshot.data))[widget.itemType];
                            var p = Pagination.fromJson(json.decode(
                                utf8.decode(snapshot.data))['pagination']);
                            AdminItemsList itemsList = AdminItemsList(items, p);
                            return Column(children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      color: Colors.black,
                                      child: TextField(
                                        controller: queryController,
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
                                            title: Text(
                                                '${itemsList.items[index]['name']}'),
                                            leading: Image.network(
                                                '${itemsList.items[index]['mini_avatar']}'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(Icons.star,
                                                    color: Colors.yellow),
                                                Text(itemsList.items[index]
                                                        ['rate']
                                                    .toString())
                                              ],
                                            )),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/admin/item_card",
                                              arguments: {
                                                'id': itemsList.items[index]
                                                    ['_id'],
                                                'itemType': widget.itemType,
                                              }).then((_user) {
                                            setState(() {
                                              queryController.text = '';
                                              query = '';
                                            });
                                          });
                                        },
                                      ));
                                    }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      color: Colors.black,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: makePagination(
                                              itemsList.pagination))))
                            ]);
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          }
                          return Center(child: CircularProgressIndicator());
                        });
                  } else if (snap2.hasError) {
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
    Map<String, String> sortMap = {
      "Новые": "time_desc",
      "Старые": "time_asc",
      "Худшие": "rate_asc",
      "Лучшие": "rate_desc",
    };
    Map<String, dynamic> confSortMap = {
      "Новые": true,
      "Подтвержденные": false,
      "Все": null,
    };
    String _url =
        'http://212.220.216.173:10501/${widget.itemType}/get_${widget.itemType}';
    // String _url = 'http://212.220.216.173:10501/admin/${widget.itemType}';
    final response = await http.post(_url,
        body: json.encode({
          'query': query,
          'page': page,
          'sorting': sortMap[currentSort],
          'notConfirmed': confSortMap[confSorting],
        }));

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
