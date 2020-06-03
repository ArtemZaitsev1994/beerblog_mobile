import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';


class LocalStorage {

  static setStr(String key, String message) async {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(key, message);
  }

  static getStr(String key) async {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      return pref.getString(key);
  }

}

Future<bool> checkAuth() async {
  if (await LocalStorage.getStr('user') != null && await LocalStorage.getStr('jwtToken') != null) {
    return true;
  }
  return false;
}

Future getCurrentUser() async {
  Map<String, Map> user = {
      'user': null
    };
  if (await checkAuth()) {
    List<String> userData = (await LocalStorage.getStr('user')).split('|');
    user['user'] = {
        'login': userData[0],
        'name': userData[1],
        'sername': userData[2],
    };
  }
  return user;
}

class SortingBloc {
  String _sorting;

  SortingBloc() {
    _sorting = "Новые";
    _actionController.stream.listen(_changeSorting);
  }

  final _sortingStream = BehaviorSubject<String>.seeded("Новые");

  Stream get changedSorting => _sortingStream.stream;
  Sink get _addSort => _sortingStream.sink;

  StreamController _actionController = StreamController();
  StreamSink get changeSorting => _actionController.sink;

  void _changeSorting(data) {
    _sorting = data;
    _addSort.add(_sorting);
  }

  void dispose() {
    _sortingStream.close();
    _actionController.close();
  }
}