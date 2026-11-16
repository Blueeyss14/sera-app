import 'package:get/get.dart';

import '../../care_plan/controllers/care_plan_controller.dart';
import '../../companion/controllers/companion_controller.dart';
import '../../doctors/controllers/doctors_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../today/controllers/today_controller.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<TodayController>(() => TodayController());
    Get.lazyPut<CarePlanController>(() => CarePlanController());
    Get.lazyPut<CompanionController>(() => CompanionController());
    Get.lazyPut<DoctorsController>(() => DoctorsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

