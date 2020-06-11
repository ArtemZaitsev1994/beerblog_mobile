import 'dart:convert';

import 'package:beerblog/common/jsonModels.dart';
import 'package:beerblog/elems/appbar.dart';
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
        appBar: MainAppBar(),
        body: FutureBuilder<BarDataItem>(
            future: _getBarItem(barId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _drawItem(snapshot.data.bar);
              } else if (snapshot.hasError) {
                return Text('Error');
              }
              return Center(child: CircularProgressIndicator());
            })
      );
  }

  Future<BarDataItem> _getBarItem(String _id) async {
    const url = 'http://212.220.216.173:10501/bar/get_bar_item';
    final response = await http.post(url, body: json.encode({'id': _id}));

    if (response.statusCode == 200) {
      BarDataItem answer =
          BarDataItem.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return answer;
    }
    throw Exception('Error: ${response.reasonPhrase}');
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

}
