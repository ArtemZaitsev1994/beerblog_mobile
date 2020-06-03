// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jsonModels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandartAnswer _$StandartAnswerFromJson(Map<String, dynamic> json) {
  return StandartAnswer(
    success: json['success'] as bool,
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$StandartAnswerToJson(StandartAnswer instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

RatingAnswer _$RatingAnswerFromJson(Map<String, dynamic> json) {
  return RatingAnswer(
    success: json['success'] as bool,
    message: json['message'] as String,
  )..newRate = json['newRate'] as int;
}

Map<String, dynamic> _$RatingAnswerToJson(RatingAnswer instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'newRate': instance.newRate,
    };
