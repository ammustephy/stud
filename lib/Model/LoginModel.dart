import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final bool success;
  final String message;
  final LoginData data;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}

class LoginData extends Equatable {
  final String token;
  final int userId;
  final String username;
  final List<String> groups;
  final bool firstLogin;

  const LoginData({
    required this.token,
    required this.userId,
    required this.username,
    required this.groups,
    required this.firstLogin,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.parse(json['user_id'].toString()),
      username: json['username'] as String,
      groups: List<String>.from(json['groups'] as List<dynamic>),
      firstLogin: json['first_login'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
      'username': username,
      'groups': groups,
      'first_login': firstLogin,
    };
  }

  @override
  List<Object?> get props => [token, userId, username, groups, firstLogin];
}
