import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../res/constant.dart';
import '../../src/routes/app_routes.dart';
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

  Future<AuthUser?> getMe() async {
    try {
      final url = Uri.parse('$_baseUrl/auth/me');
      final resData = await _get(url);
      final data = resData['data'] as Map<String, dynamic>;
      final updatedUser = AuthUser.fromJson(data);
      await SessionService.to.saveUser(updatedUser);
      return updatedUser;
    } catch (_) {
      return null;
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

    final resData = await _post(url, body: body);
    final data = resData['data'] as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

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

  Future<DoctorAvailableSlots?> getDoctorAvailableSlots(String doctorId, [String? date]) async {
    final q = date != null && date.isNotEmpty ? '?date=$date' : '';
    final url = Uri.parse('$_baseUrl/patient/doctors/$doctorId/available-slots$q');
    try {
      final resData = await _get(url);
      final data = resData['data'];
      if (data == null) return null;
      return DoctorAvailableSlots.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getDoctorAvailableDates(String doctorId) async {
    final url = Uri.parse('$_baseUrl/patient/doctors/$doctorId/available-dates');
    try {
      final resData = await _get(url);
      final list = resData['data'] as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> requestConsultation({
    required String doctorId,
    String? scheduledDate,
    String? scheduledTime,
    String? notes,
  }) async {
    final body = jsonEncode({
      'doctorId': doctorId,
      if (scheduledDate != null && scheduledDate.isNotEmpty) 'scheduledDate': scheduledDate,
      if (scheduledTime != null && scheduledTime.isNotEmpty) 'scheduledTime': scheduledTime,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    try {
      final url = Uri.parse('$_baseUrl/patient/consultations');
      final resData = await _post(url, body: body);
      return resData['data'] as Map<String, dynamic>? ?? {};
    } catch (_) {
      final fallbackUrl = Uri.parse('$_baseUrl/patient/consultation-requests');
      final resData = await _post(fallbackUrl, body: body);
      return resData['data'] as Map<String, dynamic>? ?? {};
    }
  }

  Future<List<ConsultationRequestItem>> getConsultationRequests() async {
    try {
      final url = Uri.parse('$_baseUrl/patient/consultations');
      final resData = await _get(url);
      final list = resData['data'] as List<dynamic>? ?? [];
      return list.map((e) => ConsultationRequestItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final fallbackUrl = Uri.parse('$_baseUrl/patient/consultation-requests');
      final resData = await _get(fallbackUrl);
      final list = resData['data'] as List<dynamic>? ?? [];
      return list.map((e) => ConsultationRequestItem.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> cancelConsultation(String requestId) async {
    final url = Uri.parse('$_baseUrl/patient/consultation-requests/$requestId/cancel');
    await _post(url);
  }

  Future<void> connectWearable([String? deviceName]) async {
    final url = Uri.parse('$_baseUrl/patient/wearable/connect');
    final body = jsonEncode({
      if (deviceName != null && deviceName.isNotEmpty) 'deviceName': deviceName,
      'deviceModel': 'KIM-B19',
    });
    await _post(url, body: body);
  }

  Future<WearableStatus> getWearableStatus() async {
    final url = Uri.parse('$_baseUrl/patient/wearable/status');
    final resData = await _get(url);
    return WearableStatus.fromJson(resData['data'] as Map<String, dynamic>);
  }

  Future<void> syncWearable([String? deviceName]) async {
    final url = Uri.parse('$_baseUrl/patient/wearable/sync');
    final body = jsonEncode(deviceName != null && deviceName.isNotEmpty ? {'deviceName': deviceName} : {});
    await _post(url, body: body);
  }

  Future<void> disconnectWearable() async {
    final url = Uri.parse('$_baseUrl/patient/wearable/disconnect');
    await _post(url);
  }

  Future<DailyWearableData?> getDailyWearable([String? date]) async {
    final q = date != null && date.isNotEmpty ? '?date=$date' : '';
    final url = Uri.parse('$_baseUrl/patient/wearable/daily$q');
    try {
      final resData = await _get(url);
      final data = resData['data'];
      if (data == null) return null;
      return DailyWearableData.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<WearableDayTrends?> getWearableDayTrends([String? anchorDate]) async {
    final q = anchorDate != null && anchorDate.isNotEmpty ? '&anchor=$anchorDate' : '';
    final url = Uri.parse('$_baseUrl/patient/wearable/trends?period=day$q');
    try {
      final resData = await _get(url);
      final data = resData['data'];
      if (data == null) return null;
      return WearableDayTrends.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<MetricTrend?> getWearableMetricTrend({
    required String metric,
    String period = 'day',
    String? anchorDate,
  }) async {
    final anchorParam = anchorDate != null && anchorDate.isNotEmpty ? '&anchor=$anchorDate' : '';
    final url = Uri.parse('$_baseUrl/patient/wearable/trends?period=$period&metric=$metric$anchorParam');
    try {
      final resData = await _get(url);
      final data = resData['data'];
      if (data == null) return null;
      return MetricTrend.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<FeedbackEntry>> getFeedbacks() async {
    final url = Uri.parse('$_baseUrl/patient/feedback');
    try {
      final resData = await _get(url);
      final list = resData['data'] as List<dynamic>? ?? [];
      return list.map((e) => FeedbackEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> sendFeedback({required String category, required String message}) async {
    final url = Uri.parse('$_baseUrl/patient/feedback');
    final body = jsonEncode({'category': category, 'message': message});
    await _post(url, body: body);
  }

  Future<List<HealthHistoryEntry>> getPatientHistory(String patientId) async {
    final url = Uri.parse('$_baseUrl/hospital/patients/$patientId/history');
    final resData = await _get(url);
    final list = resData['data'] as List<dynamic>? ?? [];
    return list.map((e) => HealthHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Patient?> getPatientDetail(String patientId) async {
    try {
      final url = Uri.parse('$_baseUrl/hospital/patients/$patientId');
      final resData = await _get(url);
      return Patient.fromJson(resData['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

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

    if (response.statusCode == 401) {
      SessionService.to.clearSession();
      Get.offAllNamed(AppRoutes.auth);
      throw ApiException('Session expired. Please log in again.', 401);
    }

    final message = json['message']?.toString() ??
        json['error']?.toString() ??
        'Request failed with status: ${response.statusCode}';
    throw ApiException(message, response.statusCode);
  }
}
