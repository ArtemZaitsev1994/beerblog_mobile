import 'package:beerblog/screens/admin/admin.dart';
import 'package:beerblog/screens/admin/adminItemsList.dart';
import 'package:beerblog/screens/admin/itemCard.dart';
import 'package:beerblog/screens/auth/authScreen.dart';
import 'package:beerblog/screens/auth/changePassword.dart';
import 'package:beerblog/screens/bar/barCard.dart';
import 'package:beerblog/screens/bar/barList.dart';
import 'package:beerblog/screens/beer/beerCard.dart';
import 'package:beerblog/screens/beer/beerList.dart';
import 'package:beerblog/screens/information/information.dart';
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
          '/bar': (context) => BarList(),

          '/beer_item': (context) => BeerItem(),
          '/wine_item': (context) => WineItem(),
          '/bar_item': (context) => BarItem(),

          '/info': (context) => Information(),
          '/admin': (context) => AdminPanelScreen(),
          '/admin/beer': (context) => AdminItemsListScreen(itemType: 'beer'),
          '/admin/wine': (context) => AdminItemsListScreen(itemType: 'wine'),
          '/admin/bar': (context) => AdminItemsListScreen(itemType: 'bar'),
          
          '/admin/item_card': (context) => AdminItemCard(),
          
          '/auth': (context) => Auth(),
          '/auth/change_password': (context) => ChangePasswordScreen(),
        });
  }
}