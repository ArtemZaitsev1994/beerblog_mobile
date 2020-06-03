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
