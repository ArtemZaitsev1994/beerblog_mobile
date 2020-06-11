import 'dart:convert';

import 'package:beerblog/common/jsonModels.dart';
import 'package:beerblog/elems/comments.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:beerblog/screens/auth/authJson.dart';
import 'package:beerblog/screens/beer/beerJson.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../../common/utils.dart';

class BeerItem extends StatefulWidget {
  @override
  _BeerItemState createState() => _BeerItemState();
}

class _BeerItemState extends State<BeerItem> {
  var user;
  String comment;
  String beerId;
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

    String beerId = settings.arguments;
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
        body: FutureBuilder<BeerDataItem>(
            future: _getBeerItem(beerId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _drawItem(snapshot.data.beer);
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

  Future<BeerDataItem> _getBeerItem(String _id) async {
    const url = 'http://212.220.216.173:10501/beer/get_beer_item';
    final response = await http.post(url, body: json.encode({'id': _id}));

    if (response.statusCode == 200) {
      BeerDataItem answer =
          BeerDataItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return answer;
    }
    throw Exception('Error: ${response.reasonPhrase}');
  }

  Widget _drawItem(item) {
    beerId = item.beerId;
    comments = item.comments;
    rating = item.rate;
    if (user != null){
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
            Row(children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Text('Алкоголь %:\n',
                        style: Theme.of(context).textTheme.headline2),
                    Text("${item.alcohol}",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Text('Плотность:\n',
                        style: Theme.of(context).textTheme.headline2),
                    Text("${item.fortress}",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Text('IBU:\n',
                        style: Theme.of(context).textTheme.headline2),
                    Text("${item.ibu}",
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
            ]),
            Divider(),
            Row(children: <Widget>[
              Text("Производитель:\n",
                  style: Theme.of(context).textTheme.headline2),
            ]),
            Row(children: <Widget>[
              Text("${item.manufacturer}",
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
            Divider(),
            Row(children: <Widget>[
              Text("Примечание:\n",
                  style: Theme.of(context).textTheme.headline2),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Text("${item.others}",
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
            user != null ?
            Icon(Icons.star_border) : SizedBox.shrink(),
          ]));
          
      _third = Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              commonRate,
              user != null ?
              IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: _addOwnRating,
              ) : SizedBox.shrink(),
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
    const url = 'http://212.220.216.173:10501/api/add_comment';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    Map<String, dynamic> payload = {
      'alcohol_type': 'beer',
      'itemId': '$beerId',
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
    const url = 'http://212.220.216.173:10501/api/update_rate';
    String token = (await LocalStorage.getStr('jwtToken') ?? '');
    Map<String, dynamic> payload = {
      'alcohol_type': 'beer',
      'itemId': '$beerId',
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
