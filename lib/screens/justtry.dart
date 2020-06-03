import 'package:flutter/material.dart';
// погода пример
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Weather', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: null,
        ),
        iconTheme: IconThemeData(color: Colors.black54),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), onPressed: null),
        ],
      ),
      body: _buildBody(),
    ));
  }
}

Widget _buildBody() {
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        _headerImage(),
        SafeArea(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _weatherDescription(),
              Divider(),
              _temperature(),
              Divider(),
              _temperatureForcast(),
              Divider(),
              _footerRating()
            ],
          ),
        )),
      ],
    ),
  );
}

Image _headerImage() {
  return Image(
      image: NetworkImage(
          'https://www.atlantawomensnetwork.org/wp-content/uploads/2018/10/clear-instincts.jpg'),
      fit: BoxFit.cover);
}

Column _weatherDescription() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Text('Vtornik - may 34',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          )),
      Divider(),
      Text(
          'Lorem ipsum asdf masd fsaf asfasdfas fas dfr qcqe ev qvqv eqqdcvq qef qe vqe qeq we qqewd qe qefcq v req qerqwefdc vqvd aoiq;l pio mqlmelkqm ;mqf; ',
          style: TextStyle(color: Colors.black54))
    ],
  );
}

Row _temperature() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.wb_sunny, color: Colors.yellow),
        ],
      ),
      SizedBox(
        width: 16.0,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('14 * dfaasd', style: TextStyle(color: Colors.deepPurple))
            ],
          ),
          Row(
            children: <Widget>[
              Text('Verkhnii Tagil', style: TextStyle(color: Colors.grey))
            ],
          )
        ],
      )
    ],
  );
}

Wrap _temperatureForcast() {
  return Wrap(
    spacing: 10.0,
    children: List.generate(8, (int index) {
      return Chip(
          label: Text('${index + 20}*C', style: TextStyle(fontSize: 15.0)),
          avatar: Icon(
            Icons.wb_cloudy,
            color: Colors.blue.shade300
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: Colors.grey)
          ),
          backgroundColor: Colors.grey.shade100,
        );
    }),
  );
}

Row _footerRating() {
  var stars = Row(
    children: <Widget>[
      Icon(Icons.star, size: 15.0, color: Colors.yellow,),
      Icon(Icons.star, size: 15.0, color: Colors.yellow,),
      Icon(Icons.star, size: 15.0, color: Colors.yellow,),
      Icon(Icons.star, size: 15.0, color: Colors.black,),
      Icon(Icons.star, size: 15.0, color: Colors.black,),
    ],
  );
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Text(
        'Info with ingosd kmllam;a',
        style: TextStyle(fontSize: 15.0)
      ),
      stars
    ],
  );
}