import 'package:beerblog/elems/appbar.dart';
import 'package:beerblog/screens/auth/authScreen.dart';
import 'package:beerblog/screens/beer/beerCard.dart';
import 'package:beerblog/screens/beer/beerList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'elems/commonPadding.dart';
import 'elems/mainDrawer.dart';
import 'screens/homepage/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: 'PTSansCaption',
            textTheme: TextTheme(
                headline1: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          // offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                headline2: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          // offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                bodyText1: TextStyle(
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          blurRadius: 1,
                          color: Colors.black,
                          // offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
              )
            ),
        home: _buildPage(HomePage(), MainAppBar()),
        routes: {
          '/beer': (context) => BeerList(),
          '/auth': (context) => _buildPage(Auth(), MainAppBar()),
          '/beer_item': (context) => BeerItem()
        });
  }
}

Widget _buildPage(w, appBar) {
  return Scaffold(
    appBar: appBar,
    body: commonPadding(w),
    drawer: MainDrawer(),
  );
}
