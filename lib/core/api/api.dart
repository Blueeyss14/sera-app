import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../res/constant.dart';
import '../config/config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AuthUser {
  final String id;
  final String role;
  final String email;
  final String name;
  final String? phone;
  final bool isVerified;
  final String? patientId;
  final String? doctorId;

  AuthUser({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    this.phone,
    required this.isVerified,
    this.patientId,
    this.doctorId,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      isVerified: json['isVerified'] == true,
      patientId: json['patientId']?.toString(),
      doctorId: json['doctorId']?.toString(),
    );
  }
}

class AuthResponse {
  final AuthUser user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
    );
  }
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  String get _baseUrl => BaseConfigs.baseUrl;

  Map<String, String> _buildHeaders([String? token]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<AuthResponse> loginPatient({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl${EndpointStrings.patientLogin}');
    final body = jsonEncode({
      'email': email.trim(),
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: body,
      );

      final Map<String, dynamic> resData = _parseResponse(response);
      final data = resData['data'] as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } on SocketException {
      throw ApiException(AppStrings.networkError, 0);
    } on http.ClientException {
      throw ApiException(AppStrings.networkError, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<AuthResponse> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
    required bool hasAcceptedTerms,
  }) async {
    final url = Uri.parse('$_baseUrl${EndpointStrings.patientRegister}');
    final body = jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
      'hasAcceptedTerms': hasAcceptedTerms,
    });

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: body,
      );

      final Map<String, dynamic> resData = _parseResponse(response);
      final data = resData['data'] as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } on SocketException {
      throw ApiException(AppStrings.networkError, 0);
    } on http.ClientException {
      throw ApiException(AppStrings.networkError, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Server returned an invalid response (${response.statusCode})',
        response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (json['success'] == true) {
        return json;
      }
    }

    final message = json['message']?.toString() ??
        json['error']?.toString() ??
        'Request failed with status: ${response.statusCode}';
    throw ApiException(message, response.statusCode);
  }
}
