import 'package:json_annotation/json_annotation.dart';

part 'authJson.g.dart';


@JsonSerializable()
class AuthData {
  bool success;
  String token;
  String message;
  String auth_link;
  bool invalid_token;
  User user;

  AuthData({this.success, this.token, this.message, this.auth_link, this.invalid_token});

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class User {
  String name;
  String email;
  String login;
  String sername;

  User({this.name, this.email, this.login, this.sername});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}