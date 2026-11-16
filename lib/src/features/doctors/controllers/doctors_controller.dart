import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';

class DoctorsController extends GetxController {
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = true.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  Future<void> fetchDoctors([String? query]) async {
    isLoading.value = true;
    try {
      final list = await ApiService.instance.getDoctors(query);
      doctors.value = list;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestConsultation(String doctorId, [String? notes]) async {
    try {
      await ApiService.instance.requestConsultation(doctorId, notes);
      await fetchDoctors(searchController.text);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

