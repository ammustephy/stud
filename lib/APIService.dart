import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stud/Model/AttendanceModel.dart';
import 'package:stud/Model/LoginModel.dart';


class ApiService {
  // static const String _baseUrl = 'http://192.168.1.56:8000';
  static const String _baseUrl = 'https://pegado.in/backend';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'userToken');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'userId');
  }

  Future<void> deleteUserId() async {
    await _secureStorage.delete(key: 'userId');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/user/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      log('Login Status Code: ${response.statusCode}');
      log('Login Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonMap);
        if (loginResponse.success) {
          await _secureStorage.write(key: 'userToken', value: loginResponse.data.token);
          await _secureStorage.write(key: 'userId', value: loginResponse.data.userId.toString());
          log('Token stored successfully: ${loginResponse.data.token}');
          log('User ID stored successfully: ${loginResponse.data.userId}');
          return {'success': true, 'data': loginResponse.data.toJson()};
        } else {
          return {'success': false, 'error': loginResponse.message};
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'error': data['error'] ?? data['message'] ?? 'Login failed',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Unexpected response: ${response.body}'
          };
        }
      }
    } catch (e) {
      log('Login Error: $e'); // Debug log
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<AttendanceResponse> fetchAttendance(DateTime date) async {
    final token = await getToken();
    final userId = await getUserId();

    if (token == null || userId == null) {
      throw Exception('Not authenticated. Please login again.');
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final requestBody = jsonEncode({
      'student_id': userId,
      'date': formattedDate,
      'status_id': 1,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    log('Attendance Request Headers: $headers', name: 'ApiService');
    log('Attendance Request Body: $requestBody', name: 'ApiService');

    final response = await http.post(
      Uri.parse('$_baseUrl/pre-exam/api/studentattendancedetails/'),
      headers: headers,
      body: requestBody,
    );

    log('Attendance Response Status Code: ${response.statusCode}', name: 'ApiService');
    log('Attendance Response Headers: ${response.headers}', name: 'ApiService');
    log('Attendance Response Body: ${response.body}', name: 'ApiService');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AttendanceResponse.fromJson(json);
    } else {
      throw Exception('Failed to fetch attendance. Status code: ${response.statusCode}');
    }
  }
}


