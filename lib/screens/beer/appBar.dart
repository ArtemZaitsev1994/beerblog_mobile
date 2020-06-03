import 'package:beerblog/screens/beer/sorting.dart';
import 'package:flutter/material.dart';

class AppBarWithSorting extends StatelessWidget with PreferredSizeWidget {
  SortingBloc sorting = SortingBloc();


  @override
  Widget build(BuildContext context){
    return AppBar(
        title: StreamBuilder<String>(
            stream: sorting.changedSorting,
            builder: (context, snapshot) {
              return AppBar(
                title: Text(
                  'BeerBlog',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.black,
                actions: <Widget>[
                  DropdownButton<String>(
                    value: snapshot.data,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    onChanged: (String newValue) {
                      sorting.changeSorting.add(newValue);
                    },
                    items: <String>[
                      "time_asc",
                      "time_desc",
                      "rate_asc",
                      "rate_desc"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  )
                ],
              );
            }),
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  // List<Widget> getSortSettings() {
  //   return [MyStatefulWidget()];
  // }
}

// class MyStatefulWidget extends StatefulWidget {
//   MyStatefulWidget({Key key}) : super(key: key);

//   @override
//   _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   String dropdownValue = 'One';

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<String>(
//       value: dropdownValue,
//       icon: Icon(Icons.arrow_downward),
//       iconSize: 24,
//       elevation: 16,
//       style: TextStyle(color: Colors.white),
//       underline: Container(
//         height: 2,
//         color: Colors.white,
//       ),
//       onChanged: (String newValue) {
//         setState(() {
//           dropdownValue = newValue;
//         });
//       },
//       items: <String>['c', 'Раньше', 'По убыванию оценки', 'По возрастанию оценки']
//           .map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
//   }
// }