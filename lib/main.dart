import 'package:beerblog/screens/auth/authScreen.dart';
import 'package:beerblog/screens/beer/beerCard.dart';
import 'package:beerblog/screens/beer/beerList.dart';
import 'package:beerblog/screens/wine/wineCard.dart';
import 'package:beerblog/screens/wine/wineList.dart';
import 'package:flutter/material.dart';
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
        home: HomePage(),
        routes: {
          '/beer': (context) => BeerList(),
          '/wine': (context) => WineList(),
          '/auth': (context) => Auth(),
          '/beer_item': (context) => BeerItem(),
          '/wine_item': (context) => WineItem(),
        });
  }
}