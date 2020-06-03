import 'dart:io';

import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/wine/wineJson.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WineList extends StatefulWidget {
  const WineList({Key key}) : super(key: key);
  @override
  _WineListState createState() => _WineListState();
}

class _WineListState extends State<WineList>
    with SingleTickerProviderStateMixin {
// Общий класс для алкоголя, нужно переписать методы
//   _firstScreen
//   _secondScreen
//   _drawNewAlcoholItemForm
//   _sendAlcoholItem
  SortingBloc sorting = SortingBloc();
  bool needSort = true;
  var user;
  int page = 1;
  final urlListItems = 'http://212.220.216.173:10501/wine/get_wine';
  List<String> sortItems = ["Новые", "Старые", "Лучшие", "Худшие"];
  String currentSort;
  String serverAnswer = '';
  TextStyle serverAnswerStyle;
  SharedPreferences localStorage;
  String emptyString;
  String userName;

  String wineName;
  String manufacturer;
  double alcohol;
  double fortress;
  double ibu;
  String review;
  double rate = 50;
  File file;
  String others;
  TabController _tabController;

  List<Widget> screenNames = [Text('Просмотр'), Text('Добавить новое')];
  List<Widget> screens;

  static List<String> styles = ['Белое', 'Красное', 'Розовое', 'Игристое', 'Фруктовое', 'Другое'];
  static List<String> sugarStyles = ['Сладкое', 'Полусладкое', 'Полусухое', 'Сухое', 'Другое'];
  String style;
  String sugar;

  @override
  void initState() {
    super.initState();
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
              return _drawNewAlcoholItemForm(snapshot.data['user']);
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
              future: getAlcoholList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WineData wineList = WineData.fromJson(json.decode(utf8.decode(snapshot.data)));
                  return Column(children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Container(
                            color: Colors.black,
                            child: TextField(
                                decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Поиск (пока не работает ):',
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              filled: true,
                            )))),
                    Expanded(
                      flex: 9,
                      child: ListView.builder(
                          itemCount: wineList.wine.length,
                          itemBuilder: (context, index) {
                            return Card(
                                child: InkWell(
                              child: ListTile(
                                  title:
                                      Text('${wineList.wine[index].name}'),
                                  leading: Image.network(
                                      '${wineList.wine[index].mini_avatar}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.star, color: Colors.yellow),
                                      Text(wineList.wine[index].rate
                                          .toString())
                                    ],
                                  )),
                              onTap: () {
                                Navigator.pushNamed(context, "/wine_item",
                                    arguments:
                                        wineList.wine[index].wineId);
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
                                    makePagination(wineList.pagination))))
                  ]);
                } else if (snapshot.hasError) {
                  return Text('Error');
                }
                return Center(child: CircularProgressIndicator());
              });
        });
  }

  Widget _drawNewAlcoholItemForm(_user) {
    user = _user;
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text('Добавить вино в коллекцию',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Название',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    wineName = value;
                  });
                }),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Проиводитель',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    manufacturer = value;
                  });
                }),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Алкоголь %',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          alcohol = double.parse(value);
                        });
                      }),
                )),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(
                          color: Colors.black54, style: BorderStyle.solid, width: 0.80),
                    ),
                    child: DropdownButton<String>(
                      value: style,
                      hint: Text('Стиль'),
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
                      onChanged: (String newValue) {
                        setState(() {
                          style = newValue;
                        });
                      },
                      items: styles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.19,
                            child: Text(value.toString(),
                                style: TextStyle(color: Colors.black)),
                          )
                        );
                      }).toList(),
                    ),
                )),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(
                          color: Colors.black54, style: BorderStyle.solid, width: 0.80),
                    ),
                    child: DropdownButton<String>(
                      value: sugar,
                      hint: Text('Вид'),
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: Colors.white),
                      onChanged: (String newValue) {
                        setState(() {
                          sugar = newValue;
                        });
                      },
                      items: sugarStyles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.19,
                            child: Text(value.toString(),
                                style: TextStyle(color: Colors.black)),
                          )
                        );
                      }).toList(),
                    ),
                )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Описание',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    review = value;
                  });
                }),
            SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text("Оценка: $rate"),
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
                value: rate,
                onChanged: (value) {
                  setState(() {
                    rate = value.truncateToDouble();
                  });
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Примечание (где брал, за сколько и тд...)',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    others = value;
                  });
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: _showDialog,
                  child: Text('Выбрать фото'),
                ),
                SizedBox(width: 10.0),
                RaisedButton(
                  onPressed: _sendAlcoholItem,
                  child: Text('Загрузить вино'),
                )
              ],
            ),
            Text(serverAnswer, style: serverAnswerStyle),
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
      serverAnswer = '';
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
  }

  void _makePhotoByCamera() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);
  }

  void _sendAlcoholItem() async {
    List<String> errors = [];

    if (wineName == null) {
      errors.add('Название');
    }
    if (alcohol == null) {
      errors.add('Алкоголь %');
    }
    if (style == null) {
      errors.add('Стиль');
    }
    if (review == null) {
      errors.add('Описание');
    }
    if (errors.length > 0) {
      setState(() {
        serverAnswer = 'Не заполнены поля $errors';
        serverAnswerStyle = TextStyle(color: Colors.red);
      });
      return;
    }

    var newBeerData = Map<String, dynamic>();
    newBeerData = {
      'name': wineName.toString(),
      'manufacturer': manufacturer == null ? null : manufacturer.toString(),
      'alcohol': alcohol.toDouble(),
      'style': style.toString(),
      'sugar': sugar == null ? null : sugar.toString(),
      'review': review.toString(),
      'rate': rate.toInt(),
      'others': others == null ? null : others.toString(),
      'alcohol_type': 'wine',
      'photos': file == null
          ? null
          : await MultipartFile.fromFile(file.path, filename: 'filename'),
    };
    FormData formData = FormData.fromMap(newBeerData);

    String token = (await LocalStorage.getStr('jwtToken') ?? '');

    const url = 'http://212.220.216.173:10501/api/save_item';

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

    if (response.statusCode == 200) {
      if (response.data['success']) {
        setState(() {
          serverAnswer = 'Вино $wineName успешно добавлено.';
          serverAnswerStyle = TextStyle(color: Colors.green);
        });
      } else {
        setState(() {
          serverAnswer = '${response.data['message']}';
          serverAnswerStyle = TextStyle(color: Colors.red);
        });
      }
    }
  }

  getAlcoholList() async {
    var sortMap = {
      "Новые": "time_desc",
      "Старые": "time_asc",
      "Худшие": "rate_asc",
      "Лучшие": "rate_desc",
    };

    final response = await http.post(urlListItems,
        body: json.encode({'page': page, 'sorting': sortMap[currentSort]}));

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
