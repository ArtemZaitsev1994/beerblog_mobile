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

VersionAnswer _$VersionAnswerFromJson(Map<String, dynamic> json) {
  return VersionAnswer(
    curVersion: json['curVersion'] as String,
    actual: json['actual'] as String,
    link: json['link'] as String,
    isValid: json['isValid'] as bool,
    changes: (json['changes'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList(),
  );
}

Map<String, dynamic> _$VersionAnswerToJson(VersionAnswer instance) =>
    <String, dynamic>{
      'curVersion': instance.curVersion,
      'actual': instance.actual,
      'link': instance.link,
      'isValid': instance.isValid,
      'changes': instance.changes,
    };
