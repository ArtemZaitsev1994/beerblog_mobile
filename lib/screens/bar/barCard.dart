import 'dart:convert';

import 'package:beerblog/common/constants.dart';
import 'package:beerblog/common/jsonModels.dart';
import 'package:beerblog/elems/comments.dart';
import 'package:beerblog/screens/bar/barJson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../common/utils.dart';

class BarItem extends StatefulWidget {
  @override
  _BarItemState createState() => _BarItemState();
}

class _BarItemState extends State<BarItem> {
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

    String barId = settings.arguments;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            'BeerBlog',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder<BarDataItem>(
            future: _getBarItem(barId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _drawItem(snapshot.data.bar);
              } else if (snapshot.hasError) {
                return Text('Error');
              }
              return Center(child: CircularProgressIndicator());
            }),
        bottomNavigationBar: FutureBuilder(
            future: getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data['user'] != null) {
                  user = snapshot.data['user'];
                  return _drawCommentField();
                }
              }
              return SizedBox.shrink();
            }));
  }

  Future<BarDataItem> _getBarItem(String _id) async {
    const url = '$serverAPI/bar/get_bar_item';
    final response = await http.post(url, body: json.encode({'id': _id}));

    if (response.statusCode == 200) {
      BarDataItem answer =
          BarDataItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return answer;
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

  Future<Widget> _generateSite(item, context) async {
    List<Widget> result = [];
    Column columnResult = Column(children: result);
    String site = item.site;
    String googleSearch =
        'https://www.google.com/search?q=бар+${item.name.replaceAll(' ', '+')}+${item.city}&oq=бар+${item.name.replaceAll(' ', '+')}+${item.city}';
    Widget googleSearchWidget =
        generateLinkLine(googleSearch, 'Поискать в гугл.');

    result.add(googleSearchWidget);
    try {
      final response = await http.get('http://$site');
      if (response.statusCode != 200) {
        return columnResult;
      }
    } catch (e) {
      return columnResult;
    }
    result.insert(0, Text('или'));
    result.insert(0, generateLinkLine('http://$site', site));
    return columnResult;
  }

  Widget generateLinkLine(String url, title) {
    return Center(
      child: new InkWell(
          child: new Text(
            title,
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 20,
                decoration: TextDecoration.underline,
                color: Colors.blue),
          ),
          onTap: () => launch(url)),
    );
  }

  Widget _drawItem(item) {
    barId = item.barId;
    comments = item.comments;
    rating = item.rate;
    if (user != null) {
      yourRate = item.rates[user['login']];
    }
    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: item.avatar,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _drawRating(item)),
            Divider(),
            Row(
              children: <Widget>[
              Column(children: [
                Text("Сайт:\n", style: Theme.of(context).textTheme.headline2)
              ]),
              Expanded(
                flex: 1,
                child: 
              Center(child: FutureBuilder<Widget>(
                  future: _generateSite(item, context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data;
                    } else if (snapshot.hasError) {
                      return Text('Error');
                    }
                    return Center(child: CircularProgressIndicator());
                  }),))
            ]),
            Divider(),
            Row(children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Страна:\n',
                        style: Theme.of(context).textTheme.headline2),
                    Text("${item.country}",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Город:\n',
                        style: Theme.of(context).textTheme.headline2),
                    Text("${item.city}",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              )
            ]),
            Divider(),
            Row(children: <Widget>[
              Text("Адрес:\n", style: Theme.of(context).textTheme.headline2),
            ]),
            Row(children: <Widget>[
              Text("${item.address}",
                  style: Theme.of(context).textTheme.bodyText1),
            ]),
            Divider(),
            Row(children: <Widget>[
              Text("Время работы:\n",
                  style: Theme.of(context).textTheme.headline2),
            ]),
            Row(children: <Widget>[
              Text("${item.worktime}",
                  style: Theme.of(context).textTheme.bodyText1),
            ]),
            Divider(),
            Row(children: <Widget>[
              Text("Описание:\n", style: Theme.of(context).textTheme.headline2),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Text("${item.review}",
                    // maxLines: 10,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1),
              )
            ]),
            Divider(
              color: Colors.black,
              height: 20,
              thickness: 2,
            ),
            CommentsList(
              comments: comments,
            )
          ],
        ));
  }

  List<Widget> _drawRating(item) {
    Color _color;
    Widget _second;
    Widget _third;
    List<Widget> result = [
      Expanded(
        flex: 8,
        child: Center(
          child: Text("${item.name}",
              // maxLines: 10,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.headline1),
        ),
      ),
    ];
    Widget commonRate = Text("$rating",
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headline2);

    if (yourRate != null) {
      if (item.rate == yourRate) {
        _color = Colors.yellow;
      } else if (item.rate > yourRate) {
        _color = Colors.green;
      } else {
        _color = Colors.red;
      }
      _second = Expanded(
          flex: 1,
          child: Column(children: <Widget>[
            Icon(
              Icons.star,
              color: _color,
            ),
            Icon(
              Icons.star,
              color: Colors.yellow,
            )
          ]));
      _third = Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              commonRate,
              Text("$yourRate",
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.headline2),
            ],
          ));
    } else {
      _second = Expanded(
          flex: 1,
          child: Column(children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            user != null ? Icon(Icons.star_border) : SizedBox.shrink(),
          ]));

      _third = Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              commonRate,
              user != null
                  ? IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: _addOwnRating,
                    )
                  : SizedBox.shrink(),
            ],
          ));
    }

    Expanded ratingBox = Expanded(
        flex: 2,
        child: GestureDetector(
            onTap: _addOwnRating,
            child: Row(
              children: <Widget>[_second, _third],
            )));

    result.add(ratingBox);
    return result;
  }

  Widget _drawCommentField() {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TextField(
            controller: commentController,
            maxLines: 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Твой комментарий',
              fillColor: Colors.black54,
              focusColor: Colors.black,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendComment,
              ),
            ),
            onChanged: (value) {
              setState(() {
                comment = value;
              });
            }));
  }

  void _sendComment() async {
    const url = '$serverAPI/api/add_comment';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    Map<String, dynamic> payload = {
      'alcohol_type': 'bar',
      'itemId': '$barId',
      'comment': {'author': '${user['name']}', 'text': '$comment'}
    };
    final response = await http.post(url,
        headers: {'Authorization': '$token'}, body: json.encode(payload));

    if (response.statusCode == 200) {
      StandartAnswer answer =
          StandartAnswer.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      if (answer.success) {
        setState(() {
          comments.add(payload['comment']);
          FocusScope.of(context).requestFocus(FocusNode());
          clearTextInput();
        });
      }
    }
  }

  void _addOwnRating() async {
    var _rate = await showDialog(
        context: context,
        builder: (BuildContext context) =>
            NewRatePickerDialog(rating: rating.toDouble()));

    if (_rate != null) {
      sendNewRating(_rate);
    }
  }

  void sendNewRating(rate) async {
    const url = '$serverAPI/api/update_rate';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    Map<String, dynamic> payload = {
      'alcohol_type': 'bar',
      'itemId': '$barId',
      'rate': rate.toInt(),
      'login': user['login']
    };
    final response = await http.post(url,
        headers: {'Authorization': '$token'}, body: json.encode(payload));

    if (response.statusCode == 200) {
      RatingAnswer answer =
          RatingAnswer.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      if (answer.success) {
        setState(() {
          rating = answer.newRate;
        });
      }
    }
  }
}

class NewRatePickerDialog extends StatefulWidget {
  /// initial selection for the slider
  final double rating;

  const NewRatePickerDialog({Key key, this.rating}) : super(key: key);

  @override
  _NewRatePickerDialog createState() => _NewRatePickerDialog();
}

class _NewRatePickerDialog extends State<NewRatePickerDialog> {
  /// current selection of the slider
  double _rate;

  @override
  void initState() {
    super.initState();
    _rate = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 0.0, vertical: 150.0),
        child: AlertDialog(
          title: Text("Выбери новую оценку"),
          content: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.black26,
                trackShape: RoundedRectSliderTrackShape(),
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
              child: Column(children: <Widget>[
                Text('$_rate'),
                Slider(
                  min: 0,
                  max: 100,
                  value: _rate,
                  onChanged: (value) {
                    setState(() {
                      _rate = value.truncateToDouble();
                    });
                  },
                ),
              ])),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            RaisedButton(
              child: Text(
                "Отправить",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context, _rate);
              },
            ),
            FlatButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        ));
  }
}
