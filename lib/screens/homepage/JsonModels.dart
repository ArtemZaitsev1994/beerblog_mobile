import 'package:json_annotation/json_annotation.dart';

part 'JsonModels.g.dart';


@JsonSerializable()
class Quote {
  String quoteText;
  String quoteAuthor;
  String senderName;
  String senderLink;
  String quoteLink;

  Quote({this.quoteText, this.quoteAuthor, this.senderName, this.senderLink, this.quoteLink});


  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}


@JsonSerializable()
class VersionAnswer {
  String curVersion;
  String actual;
  String link;
  bool isValid;
  List<Map> changes;

  VersionAnswer({this.curVersion, this.actual, this.link, this.isValid, this.changes});


  factory VersionAnswer.fromJson(Map<String, dynamic> json) => _$VersionAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$VersionAnswerToJson(this);
}
