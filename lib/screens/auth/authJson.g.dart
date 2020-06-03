// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthData _$AuthDataFromJson(Map<String, dynamic> json) {
  return AuthData(
    success: json['success'] as bool,
    token: json['token'] as String,
    message: json['message'] as String,
    auth_link: json['auth_link'] as String,
    invalid_token: json['invalid_token'] as bool,
  )..user = json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
      'success': instance.success,
      'token': instance.token,
      'message': instance.message,
      'auth_link': instance.auth_link,
      'invalid_token': instance.invalid_token,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] as String,
    email: json['email'] as String,
    login: json['login'] as String,
    sername: json['sername'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'login': instance.login,
      'sername': instance.sername,
    };

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
