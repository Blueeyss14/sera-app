import 'package:get/get.dart';
import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';

class CarePlanController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rxn<CarePlan> activePlan = Rxn<CarePlan>();
  final RxList<CarePlan> allPlans = <CarePlan>[].obs;
  final RxString selectedCategory = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCarePlans();
  }

  Future<void> fetchCarePlans() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ApiService.instance.getPatientActivePlan(),
        ApiService.instance.getPatientCarePlans(),
      ]);

      activePlan.value = results[0] as CarePlan?;
      allPlans.value = results[1] as List<CarePlan>? ?? [];
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  List<CarePlanItem> get filteredItems {
    final plan = activePlan.value;
    if (plan == null) return [];
    if (selectedCategory.value == 'all') return plan.items;
    return plan.items.where((i) => i.kind == selectedCategory.value).toList();
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }
}

