import 'dart:convert';

import 'package:beerblog/common/constants.dart';
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
  VersionAnswer versionData;

  @override
  void initState() {
    validVersion = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return drawVersionRow(context);
  }

  Widget drawVersionRow(BuildContext context) {
    return FutureBuilder(
      future: compareVersions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          versionData = VersionAnswer.fromJson(snapshot.data);
          if (versionData.isValid) {
            return Scaffold(
              appBar: MainAppBar(),
              drawer: MainDrawer(),
              body: _drawHomePageBody(context),
              bottomSheet: _drawVersionRow(context),
            );
          } else {
            return Scaffold(
              appBar: MainAppBar(),
              body: _drawBlockUpdate(context),
              bottomSheet: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'v.$version',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  )),
            );
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

  Widget _drawVersionRow(BuildContext context) {
    if (version == versionData.actual) {
      return Padding(
        child: Row(
          children: <Widget>[
            RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  text: 'текущая версия - v.$version актуальна и доступна по ',
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
                          final url = versionData.link;
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
    } else {
      return Padding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('текущая версия - v.$version,',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
            Row(
              children: <Widget>[
                Text('актуальная - v.${versionData.actual} - ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
                GestureDetector(
                  onTap: _showPatchNotes,
                  child: Row(children: <Widget>[
                    Text('патчноут ',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        )),
                    Icon(
                      Icons.info_outline,
                      size: 15,
                      color: Colors.blue,
                    ),
                  ]),
                )
              ],
            ),
            RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  text: 'скачать актуальную вверсию можно по ',
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
                          final url = versionData.link;
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
  }

  sumNotes(List notes) {
    String result = '';
    for (var n in notes) {
      result += '* $n\n';
    }
    return result;
  }

  _showPatchNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Center(child: Text("Список изменений")),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: versionData.changes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('v.${versionData.changes[index]['version']}'),
                        subtitle: Text(
                            sumNotes(versionData.changes[index]['changes'])),
                      );
                    }),
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: RaisedButton(
                    child: new Text(
                      'Закрыть',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.black,
                    onPressed: () {
                      //saveIssue();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future compareVersions() async {
    final _url = '$serverAPI/compare_version';

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
        child: Column(children: <Widget>[
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
        ]));
  }

  Widget _drawBlockUpdate(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Center(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  children: <Widget>[
                    RichText(
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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: versionData.changes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                  'v.${versionData.changes[index]['version']}'),
                              subtitle: Text(sumNotes(
                                  versionData.changes[index]['changes'])),
                            );
                          }),
                    ),
                  ],
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
