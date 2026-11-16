import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isSyncing = false.obs;
  final Rxn<Patient> patient = Rxn<Patient>();
  final RxList<HealthHistoryEntry> history = <HealthHistoryEntry>[].obs;
  final Rxn<WearableStatus> wearable = Rxn<WearableStatus>();

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
        ApiService.instance.getPatientHistory(patientId),
        ApiService.instance.getWearableStatus(),
      ]);

      patient.value = results[0] as Patient?;
      history.value = results[1] as List<HealthHistoryEntry>? ?? [];
      wearable.value = results[2] as WearableStatus?;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncWearable() async {
    isSyncing.value = true;
    try {
      await ApiService.instance.syncWearable();
      final status = await ApiService.instance.getWearableStatus();
      wearable.value = status;
      Get.snackbar(
        'Smartwatch Synced',
        'Your health readings are up to date.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> signOut() async {
    await SessionService.to.clearSession();
    Get.offAllNamed(AppRoutes.auth);
  }
}

