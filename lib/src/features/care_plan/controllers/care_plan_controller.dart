import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';

class CarePlanController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rxn<CarePlan> activePlan = Rxn<CarePlan>();
  final RxList<CarePlan> allPlans = <CarePlan>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCarePlans();
  }

  Future<void> fetchCarePlans() async {
    isLoading.value = true;
    try {
      final plan = await ApiService.instance.getPatientActivePlan();
      activePlan.value = plan;
    } catch (_) {}

    try {
      final history = await ApiService.instance.getPatientCarePlans();
      allPlans.value = history;
    } catch (_) {}

    isLoading.value = false;
  }

  List<CarePlanItem> getItemsByKind(String kind) {
    final plan = activePlan.value;
    if (plan == null) return [];
    return plan.items.where((i) => i.kind == kind).toList();
  }
}
