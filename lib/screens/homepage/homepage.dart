import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'JsonModels.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      return Quote(quoteText: '', quoteAuthor: '');
    }
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
