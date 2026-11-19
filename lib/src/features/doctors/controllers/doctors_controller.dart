import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';

class DoctorsController extends GetxController {
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxList<ConsultationRequestItem> myRequests = <ConsultationRequestItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool actionLoading = false.obs;
  final RxBool requestsLoading = false.obs;
  final searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    fetchMyRequests();
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchDoctors(query);
    });
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

  Future<void> fetchMyRequests() async {
    requestsLoading.value = true;
    try {
      final list = await ApiService.instance.getConsultationRequests();
      myRequests.value = list;
    } catch (_) {
    } finally {
      requestsLoading.value = false;
    }
  }

  Future<Doctor?> getDoctorDetail(String doctorId) async {
    try {
      return await ApiService.instance.getDoctorById(doctorId);
    } catch (_) {
      return null;
    }
  }

  Future<DoctorAvailableSlots?> fetchAvailableSlots(String doctorId, String date) async {
    return await ApiService.instance.getDoctorAvailableSlots(doctorId, date);
  }

  Future<bool> requestConsultation({
    required String doctorId,
    String? scheduledDate,
    String? scheduledTime,
    String? notes,
  }) async {
    actionLoading.value = true;
    try {
      await ApiService.instance.requestConsultation(
        doctorId: doctorId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        notes: notes,
      );
      await fetchDoctors(searchController.text);
      await fetchMyRequests();
      return true;
    } catch (_) {
      return false;
    } finally {
      actionLoading.value = false;
    }
  }

  Future<bool> cancelConsultation(String requestId) async {
    actionLoading.value = true;
    try {
      await ApiService.instance.cancelConsultation(requestId);
      await fetchDoctors(searchController.text);
      await fetchMyRequests();
      return true;
    } catch (_) {
      return false;
    } finally {
      actionLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
