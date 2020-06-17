import 'dart:io';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/bar/barJson.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarList extends StatefulWidget {
  const BarList({Key key}) : super(key: key);
  @override
  _BarListState createState() => _BarListState();
}

class _BarListState extends State<BarList> with SingleTickerProviderStateMixin {
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
  final urlListItems = '$serverAPI/bar/get_bar';
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
    _tabController = TabController(vsync: this, length: screenNames.length);
    _tabController.addListener(_changeActions);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: _drawAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[_firstScreenFuture(), _secondScreen()],
      ),
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
      actions: userName == null
          ? <Widget>[
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
            ]
          : <Widget>[
              Padding(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                      child: Text(userName, style: TextStyle(fontSize: 18))))
            ],
      bottom: TabBar(
        controller: _tabController,
        tabs: screenNames,
      ),
    );
  }

  void _changeActions() {
    if (this._tabController.index == 0) {
      setState(() {
        userName = null;
      });
    } else {
      if (user != null) {
        setState(() {
          userName = user['name'] ?? '';
        });
      } else {
        setState(() {
          userName = '';
        });
      }
    }
  }

  Widget _secondScreen() {
    return FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['user'] != null) {
              user = snapshot.data['user'];
              return _drawNewBeerBlogItemForm(snapshot.data['user']);
            } else {
              return Column(children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                Text('Ooops...'),
                SizedBox(height: 40),
                Text('Только доверенные ребята могут добавлять.'),
                SizedBox(height: 40),
                RaisedButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.black,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, "/auth", arguments: true)
                        .then((_user) {
                      setState(() {
                        user = _user;
                        userName = user['name'];
                        emptyString = '';
                      });
                    });
                  },
                  child: new Text(
                    "Залогиниться.",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                )
              ]);
            }
          } else if (snapshot.hasError) {
            return Text('Error');
          }
          return Center(child: CircularProgressIndicator());
        });
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
                  print(utf8.decode(snapshot.data));
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

  Widget _drawNewBeerBlogItemForm(_user) {
    user = _user;
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text('Добавить бар в коллекцию',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Название**',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    barItem['barName'] = value;
                  });
                }),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Сайт',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    barItem['site'] = value;
                  });
                }),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: barItem['country']),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Страна',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                          barItem['country'] = value;
                      }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: barItem['city']),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Город',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                          barItem['city'] = value;
                      }),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Адрес',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                    barItem['address'] = value;
                }),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Часы работы',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                    barItem['worktime'] = value;
                }),
            SizedBox(height: 10),
            TextField(
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Описание**',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    barItem['review'] = value;
                  });
                }),
            SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text("Оценка: ${barItem['rate']}"),
              Icon(Icons.star, color: Colors.yellow)
            ]),
            SizedBox(
              height: 10,
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.black26,
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 4.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Colors.black,
                overlayColor: Colors.black.withAlpha(32),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                tickMarkShape: RoundSliderTickMarkShape(),
                activeTickMarkColor: Colors.black,
                inactiveTickMarkColor: Colors.black,
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Colors.redAccent,
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              child: Slider(
                min: 0,
                max: 100,
                value: barItem['rate'],
                onChanged: (value) {
                  setState(() {
                    barItem['rate'] = value.truncateToDouble();
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: _showDialog,
                  child: Text('Выбрать фото'),
                ),
                SizedBox(width: 10.0),
                RaisedButton(
                  onPressed: sendBarItem,
                  child: Text('Загрузить бар'),
                )
              ],
            ),
            serverAnswer,
            file == null ? Text('No Image Selected') : _drawPhoto(file),
          ],
        ),
      ),
    );
  }

  Stack _drawPhoto(File file) {
    return Stack(children: <Widget>[
      Image.file(file),
      Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.all(10),
        child: IconButton(
          icon: Icon(Icons.close, size: 30),
          onPressed: _removePhoto,
        ),
      )
    ]);
  }

  void _removePhoto() {
    setState(() {
      file = null;
      serverAnswerText = '';
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Откуда брать фото?"),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _makePhotoByCamera();
                  },
                  child: const Text('Камера', style: TextStyle(fontSize: 15)),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _chooseFromDevice();
                  },
                  child: const Text('Альбом', style: TextStyle(fontSize: 15)),
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
              },
            ),
          ],
        );
      },
    );
  }

  void _chooseFromDevice() async {
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      emptyString = '';
    });
  }

  void _makePhotoByCamera() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      emptyString = '';
    });
  }

  List<String> _validateBarItem(bar) {
    List<String> errors = [];

    if (bar['barName'] == null) {
      errors.add('Название');
    }
    if (bar['review'] == null) {
      errors.add('Описание');
    }
    return errors;
  }

  Future<Response> _sendBarItem() async {
    var newBeerData = Map<String, dynamic>();
    newBeerData = {
      'name': barItem['barName'].toString(),
      'review': barItem['review'].toString(),
      'address': barItem['address'] == null ? null : barItem['address'].toString(),
      'site': barItem['site'] == null ? null : barItem['site'].toString(),
      'city': barItem['city'] == null ? null : barItem['city'].toString(),
      'country': barItem['country'] == null ? null : barItem['country'].toString(),
      'rate': barItem['rate'].toInt(),
      'others': barItem['others'] == null ? null : barItem['others'].toString(),
      'photos': file == null
          ? null
          : await MultipartFile.fromFile(file.path, filename: 'filename'),
    };
    FormData formData = FormData.fromMap(newBeerData);

    String token = (await LocalStorage.getStr('jwtToken') ?? '');

    const url = '$serverAPI/bar/api/add_bar';

    Dio dio = Dio();
    Response response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': '$token',
        },
      ),
    );
    return response;
  }

  void sendBarItem() async {
    List<String> errors = _validateBarItem(barItem);
    if (errors.length > 0) {
      setState(() {
        serverAnswerText = 'Не заполнены поля $errors';
        serverAnswerStyle = TextStyle(color: Colors.red);
          serverAnswer = Text(serverAnswerText, style: serverAnswerStyle);
      });
      return;
    }

    setState(() {
      serverAnswer = Center(child: CircularProgressIndicator());
    });
    Response response = await _sendBarItem();

    if (response.statusCode == 200) {
      if (response.data['success']) {
        setState(() {
          serverAnswerText = 'Бар ${barItem['barName']} успешно добавлен.';
          serverAnswerStyle = TextStyle(color: Colors.green);
          serverAnswer = Text(serverAnswerText, style: serverAnswerStyle);
        });
      } else {
        setState(() {
          serverAnswerText = '${response.data['message']}';
          serverAnswerStyle = TextStyle(color: Colors.red);
          serverAnswer = Text(serverAnswerText, style: serverAnswerStyle);
        });
      }
    }
  }

  getItemsList() async {
    var sortMap = {
      "Новые": "time_desc",
      "Старые": "time_asc",
      "Худшие": "rate_asc",
      "Лучшие": "rate_desc",
    };

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
