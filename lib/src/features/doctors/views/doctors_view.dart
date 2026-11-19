import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/doctors_controller.dart';
import 'doctor_profile_view.dart';
import 'doctor_schedule_view.dart';
import '../widgets/active_request_banner.dart';
import '../widgets/doctor_card.dart';

class DoctorsView extends GetView<DoctorsController> {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Doctors',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ColorValues.foreground,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find trusted specialists and request a consultation directly so your care plan can be monitored by experts.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorValues.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ColorValues.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: ColorValues.foreground,
                      ),
                      onChanged: (val) => controller.onSearchChanged(val),
                      decoration: InputDecoration(
                        hintText: 'Search by doctor name, specialty, or hospital...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: ColorValues.mutedForeground,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          color: ColorValues.mutedForeground,
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: ColorValues.primary),
                  );
                }

                if (controller.doctors.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorValues.muted.withValues(alpha: 0.5),
                            ),
                            child: const Icon(
                              LucideIcons.stethoscope,
                              size: 28,
                              color: ColorValues.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No doctors found',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching with other keywords like doctor name, specialty, or hospital.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: ColorValues.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchDoctors(controller.searchController.text);
                    await controller.fetchMyRequests();
                  },
                  color: ColorValues.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    children: [
                      ActiveRequestBanner(
                        requests: controller.myRequests,
                        onCancel: (id) => controller.cancelConsultation(id),
                      ),
                      ...controller.doctors.map(
                        (doc) => DoctorCard(
                          doctor: doc,
                          onViewProfile: () => _openDoctorProfile(doc),
                          onConsult: () => _openScheduleBooking(doc),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openDoctorProfile(Doctor doc) {
    Get.to(() => DoctorProfileView(doctor: doc));
  }

  void _openScheduleBooking(Doctor doc) async {
    await Get.to(() => DoctorScheduleView(doctor: doc));
    controller.fetchDoctors(controller.searchController.text);
  }
}
