import 'dart:convert';

import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/elems/mainDrawer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'JsonModels.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool validVersion;
  String version = '0.0.1';

  @override
  void initState() {
    validVersion = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (validVersion) {
      return Scaffold(
        appBar: MainAppBar(),
        drawer: MainDrawer(),
        body: _drawHomePageBody(context),
        bottomSheet: drawVersionRow(context),
      );
    } else {
      return Scaffold(
        appBar: MainAppBar(),
        body: _drawHomePageBody(context),
        bottomSheet: drawVersionRow(context),
      );
    }
  }

  Widget drawVersionRow(BuildContext context) {
    return FutureBuilder(
      future: compareVersions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['success']) {
            if (snapshot.data['version']['isValid']) {
              return _drawVersionRow(snapshot.data['version'], context);
            } else {
              setState(() {
                validVersion = false;
              });
            }
          } else {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'v.$version',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ));
          }
        } else if (snapshot.hasError) {
          return Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'v.$version',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ));
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _drawVersionRow(Map curVersion, BuildContext context) {
    String text = curVersion['curVersion'] == curVersion['actual']
        ? 'текущая версия - v.${curVersion['curVersion']} актуальна и доступна по '
        : 'текущая версия - v.${curVersion['curVersion']},\nактуальная - v.${curVersion['actual']}\nскачать актуальную вверсию можно по ';
    return Padding(
      child: Row(
        children: <Widget>[
          RichText(
            text: TextSpan(
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                text: text,
                children: [
                  TextSpan(
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                    text: 'ссылке',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = curVersion['link'];
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            forceSafariVC: false,
                          );
                        }
                      },
                  ),
                ]),
          )
        ],
      ),
      padding: const EdgeInsets.all(10),
    );
  }

  Future compareVersions() async {
    final _url = 'http://212.220.216.173:10501/compare_version';

    try {
      final response =
          await http.post(_url, body: json.encode({'version': version}));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      // throw Exception('Error: ${response.reasonPhrase}');
    } catch (e) {
      // return empty quote
    }
    return {'success': false};
  }

  Widget _drawHomePageBody(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: validVersion
            ? Column(children: <Widget>[
                Text(
                  'Просто блог, просто заметки о пиве, вине и прочем.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Ниже умная цитата, чтобы ты спивался не просто так, а развевающиеся.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 40,
                ),
                FutureBuilder<Quote>(
                    future: _getQuota(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _drawQuote(snapshot.data);
                      } else if (snapshot.hasError) {
                        return Text('Чот пошло не так, Сообщи Тёме.');
                      }
                      return Center(child: CircularProgressIndicator());
                    })
              ])
            : Center(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(fontSize: 20, color: Colors.black),
                          text:
                              "Версия приложения слишком старая (я либо что-то поломал, либо что-то сильно починил). Нужно скачать новую версию ",
                          children: [
                            TextSpan(
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue),
                              text: 'ссылке',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = 'google.sdf';
                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      forceSafariVC: false,
                                    );
                                  }
                                },
                            ),
                          ]),
                    ))));
  }

  Future<Quote> _getQuota() async {
    final _url =
        'https://api.forismatic.com/api/1.0/?method=getQuote&format=json';

    try {
      final response = await http.get(_url);

      if (response.statusCode == 200) {
        return Quote.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      // throw Exception('Error: ${response.reasonPhrase}');
    } catch (e) {
      // return empty quote
    }
    return Quote(quoteText: '', quoteAuthor: '');
  }

  Widget _drawQuote(Quote quote) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          quote.quoteText,
          style: TextStyle(fontFamily: 'Caveat', fontSize: 22),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Align(alignment: Alignment.bottomRight, child: Text(quote.quoteAuthor))
    ]);
  }
}
