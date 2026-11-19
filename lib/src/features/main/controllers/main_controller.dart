import 'package:get/get.dart';

import '../../care_plan/controllers/care_plan_controller.dart';
import '../../doctors/controllers/doctors_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../today/controllers/today_controller.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 4) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
    } else if (index == 3) {
      if (Get.isRegistered<DoctorsController>()) {
        Get.find<DoctorsController>().fetchDoctors();
      }
    } else if (index == 1) {
      if (Get.isRegistered<CarePlanController>()) {
        Get.find<CarePlanController>().fetchCarePlans();
      }
    } else if (index == 0) {
      if (Get.isRegistered<TodayController>()) {
        Get.find<TodayController>().fetchData();
      }
    }
  }
}
