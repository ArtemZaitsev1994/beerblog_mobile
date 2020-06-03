import 'package:json_annotation/json_annotation.dart';

part 'jsonModels.g.dart';

@JsonSerializable()
class StandartAnswer {
  bool success;
  String message;

  StandartAnswer({this.success, this.message});

  factory StandartAnswer.fromJson(Map<String, dynamic> json) => _$StandartAnswerFromJson(json);
}


@JsonSerializable()
class RatingAnswer {
  bool success;
  String message;
  int newRate;

  RatingAnswer({this.success, this.message});

  factory RatingAnswer.fromJson(Map<String, dynamic> json) => _$RatingAnswerFromJson(json);
}

