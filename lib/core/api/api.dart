import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../res/constant.dart';
import '../config/config.dart';
import '../models/patient_models.dart';
import '../services/session_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  String get _baseUrl => BaseConfigs.baseUrl;

  String? get _token {
    try {
      return SessionService.to.token.value;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _buildHeaders([String? customToken]) {
    final token = customToken ?? _token;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==========================================
  // Auth
  // ==========================================

  Future<AuthResponse> loginPatient({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl${EndpointStrings.patientLogin}');
    final body = jsonEncode({
      'email': email.trim(),
      'password': password,
    });

    final resData = await _post(url, body: body);
    final data = resData['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
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

    final resData = await _post(url, body: body);
    final data = resData['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  // ==========================================
  // Reminders & Today Schedule
  // ==========================================

  Future<TodayScheduleResponse> getTodaySchedule([String? date]) async {
    final query = date != null ? '?date=$date' : '';
    final url = Uri.parse('$_baseUrl/patient/today$query');
    final resData = await _get(url);
    return TodayScheduleResponse.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<bool> toggleReminder({
    required String key,
    required String itemId,
    required String kind,
    required String date,
    String? time,
  }) async {
    final url = Uri.parse('$_baseUrl/patient/reminders/toggle');
    final body = jsonEncode({
      'key': key,
      'itemId': itemId,
      'kind': kind,
      'date': date,
      'time': time,
    });
    final resData = await _post(url, body: body);
    final data = resData['data'] as Map<String, dynamic>?;
    return data?['completed'] == true;
  }

  Future<AdherenceMetricsResponse> getPatientAdherence() async {
    final url = Uri.parse('$_baseUrl/patient/adherence');
    final resData = await _get(url);
    return AdherenceMetricsResponse.fromJson(resData['data'] as Map<String, dynamic>);
  }

  // ==========================================
  // Care Plan
  // ==========================================

  Future<CarePlan?> getPatientActivePlan() async {
    final url = Uri.parse('$_baseUrl/patient/care-plan/active');
    final resData = await _get(url);
    final data = resData['data'];
    if (data == null) return null;
    return CarePlan.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CarePlan>> getPatientCarePlans() async {
    final url = Uri.parse('$_baseUrl/patient/care-plans/history');
    final resData = await _get(url);
    final list = resData['data'] as List<dynamic>? ?? [];
    return list.map((e) => CarePlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==========================================
  // Companion AI
  // ==========================================

  Future<List<ChatMessage>> getCompanionHistory() async {
    final url = Uri.parse('$_baseUrl/companion/history');
    final resData = await _get(url);
    final list = resData['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatMessage> sendCompanionMessage(String message) async {
    final url = Uri.parse('$_baseUrl/companion/chat');
    final body = jsonEncode({'message': message});
    final resData = await _post(url, body: body);
    return ChatMessage.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<void> reportCompanionMessage(String messageId) async {
    final url = Uri.parse('$_baseUrl/companion/messages/$messageId/report');
    await _post(url);
  }

  // ==========================================
  // Doctors & Consultations
  // ==========================================

  Future<List<Doctor>> getDoctors([String? query]) async {
    final q = query != null && query.isNotEmpty ? '?q=${Uri.encodeComponent(query)}' : '';
    final url = Uri.parse('$_baseUrl/patient/doctors$q');
    final resData = await _get(url);
    final list = resData['data'] as List<dynamic>? ?? [];
    return list.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Doctor> getDoctorById(String doctorId) async {
    final url = Uri.parse('$_baseUrl/patient/doctors/$doctorId');
    final resData = await _get(url);
    return Doctor.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> requestConsultation(String doctorId, [String? notes]) async {
    final url = Uri.parse('$_baseUrl/patient/consultation-requests');
    final body = jsonEncode({
      'doctorId': doctorId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    final resData = await _post(url, body: body);
    return resData['data'] as Map<String, dynamic>? ?? {};
  }

  Future<void> cancelConsultation(String requestId) async {
    final url = Uri.parse('$_baseUrl/patient/consultation-requests/$requestId/cancel');
    await _post(url);
  }

  // ==========================================
  // Wearable (Smartwatch)
  // ==========================================

  Future<WearableStatus> getWearableStatus() async {
    final url = Uri.parse('$_baseUrl/patient/wearable/status');
    final resData = await _get(url);
    return WearableStatus.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<void> syncWearable() async {
    final url = Uri.parse('$_baseUrl/patient/wearable/sync');
    final body = jsonEncode({
      'deviceName': 'HUAWEI Band 9 (sera-1)',
      'steps': {'total': 6420, 'hourly': [200, 450, 600, 800, 1200, 1500, 1670]},
      'heartRate': {'resting': 72, 'min': 62, 'max': 118, 'hourly': [70, 75, 82, 78, 85, 74]},
      'sleep': {
        'totalMinutes': 430,
        'napMinutes': 30,
        'stages': {'deep': 120, 'light': 180, 'rem': 90, 'awake': 40},
        'bedtime': '22:30',
        'wakeTime': '06:00',
      },
      'spo2': {
        'average': 98,
        'min': 95,
        'max': 99,
        'readings': [
          {'time': '07:00', 'value': 98},
          {'time': '12:00', 'value': 99},
          {'time': '18:00', 'value': 97},
        ],
      },
    });
    await _post(url, body: body);
  }

  Future<void> disconnectWearable() async {
    final url = Uri.parse('$_baseUrl/patient/wearable/disconnect');
    await _post(url);
  }

  // ==========================================
  // Patient Records & History
  // ==========================================

  Future<List<HealthHistoryEntry>> getPatientHistory(String patientId) async {
    final url = Uri.parse('$_baseUrl/hospital/patients/$patientId/history');
    final resData = await _get(url);
    final list = resData['data'] as List<dynamic>? ?? [];
    return list.map((e) => HealthHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Patient> getPatientDetail(String patientId) async {
    final url = Uri.parse('$_baseUrl/hospital/patients/$patientId');
    final resData = await _get(url);
    return Patient.fromJson(resData['data'] as Map<String, dynamic>);
  }

  // ==========================================
  // HTTP Helpers
  // ==========================================

  Future<Map<String, dynamic>> _get(Uri url) async {
    try {
      final response = await http.get(url, headers: _buildHeaders());
      return _parseResponse(response);
    } on SocketException {
      throw ApiException(AppStrings.networkError, 0);
    } on http.ClientException {
      throw ApiException(AppStrings.networkError, 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> _post(Uri url, {String? body}) async {
    try {
      final response = await http.post(url, headers: _buildHeaders(), body: body);
      return _parseResponse(response);
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
