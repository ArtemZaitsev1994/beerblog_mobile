// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JsonModels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) {
  return Quote(
    quoteText: json['quoteText'] as String,
    quoteAuthor: json['quoteAuthor'] as String,
    senderName: json['senderName'] as String,
    senderLink: json['senderLink'] as String,
    quoteLink: json['quoteLink'] as String,
  );
}

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'quoteText': instance.quoteText,
      'quoteAuthor': instance.quoteAuthor,
      'senderName': instance.senderName,
      'senderLink': instance.senderLink,
      'quoteLink': instance.quoteLink,
    };
