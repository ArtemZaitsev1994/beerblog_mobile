import 'dart:io';

import 'package:beerblog/common/utils.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/beer/beerJson.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BeerList extends StatefulWidget {
  const BeerList({Key key}) : super(key: key);
  @override
  _BeerListState createState() => _BeerListState();
}

class _BeerListState extends State<BeerList>
    with SingleTickerProviderStateMixin {
// Общий класс для алкоголя, нужно переписать методы
//   _sendAlcoholItem
//   _firstScreen
//   _secondScreen
//   _drawNewAlcoholItemForm
  SortingBloc sorting = SortingBloc();
  bool needSort = true;
  var user;
  String userName;
  int page = 1;
  String query = '';
  final urlListItems = 'http://212.220.216.173:10501/beer/get_beer';
  List<String> sortItems = ["Новые", "Старые", "Лучшие", "Худшие"];
  String currentSort;

  String serverAnswerText = '';
  TextStyle serverAnswerStyle;
  Widget serverAnswer;

  SharedPreferences localStorage;
  String emptyString;

  String beerName;
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
                  BeerData beerList = BeerData.fromJson(json.decode(utf8.decode(snapshot.data)));
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
                            )
                          )
                        ),
                    Expanded(
                      flex: 9,
                      child: ListView.builder(
                          itemCount: beerList.beer.length,
                          itemBuilder: (context, index) {
                            return Card(
                                child: InkWell(
                              child: ListTile(
                                  title:
                                      Text('${beerList.beer[index].name}'),
                                  leading: Image.network(
                                      '${beerList.beer[index].mini_avatar}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.star, color: Colors.yellow),
                                      Text(beerList.beer[index].rate
                                          .toString())
                                    ],
                                  )),
                              onTap: () {
                                Navigator.pushNamed(context, "/beer_item",
                                    arguments:
                                        beerList.beer[index].beerId);
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
                                    makePagination(beerList.pagination))))
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
            Text('Добавить пиво в коллекцию',
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
                    beerName = value;
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
                    manufacturer = value;
                }),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Алкоголь**, %',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                          alcohol = null;
                          alcohol = double.parse(value);
                      }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Плотность**',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                          fortress = null;
                          fortress = double.parse(value);
                      }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'IBU',
                        fillColor: Colors.black54,
                        focusColor: Colors.black,
                      ),
                      onChanged: (value) {
                          ibu = null;
                          ibu = double.parse(value);
                      }),
                ),
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
                  hintText: 'Описание**',
                  fillColor: Colors.black54,
                  focusColor: Colors.black,
                ),
                onChanged: (value) {
                    review = value;
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
                    others = value;
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
                  child: Text('Загрузить пиво'),
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
      ),
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

  List<String> validateBeerItem() {
    
    List<String> errors = [];

    if (beerName == null) {
      errors.add('Название');
    }
    if (alcohol == null) {
      errors.add('Алкоголь %');
    }
    if (fortress == null) {
      errors.add('Плотность');
    }
    if (review == null) {
      errors.add('Описание');
    }
    return errors;
  }

  Future<Response> _sendBeerItem() async {
    var newBeerData = Map<String, dynamic>();
    newBeerData = {
      'name': beerName.toString(),
      'manufacturer': manufacturer == null ? null : manufacturer.toString(),
      'alcohol': alcohol.toDouble(),
      'fortress': fortress.toDouble(),
      'ibu': ibu == null ? null : ibu.toInt(),
      'review': review.toString(),
      'rate': rate.toInt(),
      'others': others == null ? null : others.toString(),
      'photos': file == null
          ? null
          : await MultipartFile.fromFile(file.path, filename: 'filename'),
    };
    FormData formData = FormData.fromMap(newBeerData);

    String token = (await LocalStorage.getStr('jwtToken') ?? '');

    const url = 'http://212.220.216.173:10501/beer/api/add_beer';

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

  void _sendAlcoholItem() async {
    List<String> errors = validateBeerItem();
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
    Response response = await _sendBeerItem();

    if (response.statusCode == 200) {
      if (response.data['success']) {
        setState(() {
          serverAnswerText = 'Пиво $beerName успешно добавлено.';
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

  getAlcoholList() async {
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
