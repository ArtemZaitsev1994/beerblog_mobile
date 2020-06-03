import 'dart:async';
import 'package:rxdart/rxdart.dart';

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