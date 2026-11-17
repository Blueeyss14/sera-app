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
      final patientId = user?.patientId ?? 'p-001';
      final results = await Future.wait([
        ApiService.instance.getPatientDetail(patientId),
        ApiService.instance.getPatientAdherence(),
        ApiService.instance.getWearableStatus(),
        ApiService.instance.getDailyWearable(),
        ApiService.instance.getFeedbacks(),
        ApiService.instance.getPatientCarePlans(),
        ApiService.instance.getWearableDayTrends(),
      ]);

      final p = results[0] as Patient?;
      if (p == null) {
        await signOut();
        return;
      }

      patient.value = p;
      adherence.value = results[1] as AdherenceMetricsResponse?;
      wearable.value = results[2] as WearableStatus?;
      dailyWearable.value = results[3] as DailyWearableData?;
      feedbacks.value = results[4] as List<FeedbackEntry>? ?? [];
      plans.value = results[5] as List<CarePlan>? ?? [];
      wearableTrends.value = results[6] as WearableDayTrends?;

      if (p.assignedDoctorId != null && p.assignedDoctorId!.isNotEmpty) {
        try {
          final doc = await ApiService.instance.getDoctorById(p.assignedDoctorId!);
          assignedDoctor.value = doc;
        } catch (_) {}
      }
    } catch (_) {
      await signOut();
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

  Future<void> signOut() async {
    await SessionService.to.clearSession();
    Get.offAllNamed(AppRoutes.auth);
  }
}
