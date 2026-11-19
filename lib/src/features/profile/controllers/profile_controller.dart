import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isDisconnecting = false.obs;
  final RxBool isConnectingWearable = false.obs;
  final RxBool isSendingFeedback = false.obs;

  final Rxn<Patient> patient = Rxn<Patient>();
  final Rxn<Doctor> assignedDoctor = Rxn<Doctor>();
  final Rxn<AdherenceMetricsResponse> adherence = Rxn<AdherenceMetricsResponse>();
  final Rxn<WearableStatus> wearable = Rxn<WearableStatus>();
  final Rxn<DailyWearableData> dailyWearable = Rxn<DailyWearableData>();
  final Rxn<WearableDayTrends> wearableTrends = Rxn<WearableDayTrends>();
  final RxList<FeedbackEntry> feedbacks = <FeedbackEntry>[].obs;
  final RxList<CarePlan> plans = <CarePlan>[].obs;

  AuthUser? get user => SessionService.to.user.value;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final me = await ApiService.instance.getMe();
      final currentUser = me ?? user;
      final patientId = currentUser?.patientId;

      final futures = <Future<dynamic>>[
        patientId != null && patientId.isNotEmpty
            ? ApiService.instance.getPatientDetail(patientId)
            : Future.value(null),
        ApiService.instance.getPatientAdherence(),
        ApiService.instance.getWearableStatus(),
        ApiService.instance.getDailyWearable(),
        ApiService.instance.getFeedbacks(),
        ApiService.instance.getPatientCarePlans(),
        ApiService.instance.getWearableDayTrends(),
      ];

      final results = await Future.wait(futures);

      final p = results[0] as Patient?;
      if (p != null) {
        patient.value = p;
      } else {
        patient.value = Patient(
          id: currentUser?.id ?? '',
          mrn: 'UNLINKED',
          name: currentUser?.name ?? 'User',
          gender: 'male',
          birthDate: '',
          phone: currentUser?.phone ?? '',
          conditions: const [],
          allergies: const [],
        );
      }

      adherence.value = results[1] as AdherenceMetricsResponse?;
      wearable.value = results[2] as WearableStatus?;
      dailyWearable.value = results[3] as DailyWearableData?;
      feedbacks.value = results[4] as List<FeedbackEntry>? ?? [];
      plans.value = results[5] as List<CarePlan>? ?? [];
      wearableTrends.value = results[6] as WearableDayTrends?;

      final docId = patient.value?.assignedDoctorId;
      if (docId != null && docId.isNotEmpty) {
        try {
          final doc = await ApiService.instance.getDoctorById(docId);
          assignedDoctor.value = doc;
        } catch (_) {}
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncWearable() async {
    isSyncing.value = true;
    try {
      await ApiService.instance.syncWearable(wearable.value?.deviceName);
      final status = await ApiService.instance.getWearableStatus();
      final daily = await ApiService.instance.getDailyWearable();
      final trends = await ApiService.instance.getWearableDayTrends();
      wearable.value = status;
      dailyWearable.value = daily;
      wearableTrends.value = trends;
      Get.snackbar(
        'Smartwatch Synced',
        'Your health readings are up to date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } catch (_) {
      Get.snackbar(
        'Sync Failed',
        'Could not sync smartwatch data.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> connectWearable([String? deviceName]) async {
    isConnectingWearable.value = true;
    try {
      await ApiService.instance.connectWearable(deviceName);
      final status = await ApiService.instance.getWearableStatus();
      final daily = await ApiService.instance.getDailyWearable();
      final trends = await ApiService.instance.getWearableDayTrends();
      wearable.value = status;
      dailyWearable.value = daily;
      wearableTrends.value = trends;
      Get.snackbar(
        'Connected',
        'Smartwatch connected successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return true;
    } catch (_) {
      Get.snackbar(
        'Connection Failed',
        'Could not connect smartwatch. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return false;
    } finally {
      isConnectingWearable.value = false;
    }
  }

  Future<void> disconnectWearable() async {
    isDisconnecting.value = true;
    try {
      await ApiService.instance.disconnectWearable();
      final status = await ApiService.instance.getWearableStatus();
      wearable.value = status;
      Get.snackbar(
        'Disconnected',
        'Smartwatch has been disconnected.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } catch (_) {
    } finally {
      isDisconnecting.value = false;
    }
  }

  Future<bool> sendFeedback(String category, String message) async {
    isSendingFeedback.value = true;
    try {
      await ApiService.instance.sendFeedback(category: category, message: message);
      final list = await ApiService.instance.getFeedbacks();
      feedbacks.value = list;
      Get.snackbar(
        'Report Sent',
        'Your report has been sent to your doctor.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return true;
    } catch (_) {
      Get.snackbar(
        'Failed',
        'Could not send report. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return false;
    } finally {
      isSendingFeedback.value = false;
    }
  }

  Future<void> updatePersonalInfo({
    required String name,
    required String? birthDate,
    required String phone,
    required String guardianName,
    required String guardianPhone,
  }) async {
    final curPatient = patient.value;
    if (curPatient != null) {
      final updatedPatient = curPatient.copyWith(
        name: name,
        birthDate: birthDate,
        phone: phone,
        guardianName: guardianName,
        guardianPhone: guardianPhone,
      );
      patient.value = updatedPatient;
    }

    final curUser = SessionService.to.user.value;
    if (curUser != null) {
      final updatedUser = curUser.copyWith(
        name: name,
        phone: phone,
      );
      await SessionService.to.saveUser(updatedUser);
    }
  }

  Future<void> signOut() async {
    await SessionService.to.clearSession();
    Get.offAllNamed(AppRoutes.auth);
  }
}
