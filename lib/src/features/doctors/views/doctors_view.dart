import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/doctors_controller.dart';

class DoctorsView extends GetView<DoctorsController> {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        title: Text(
          'Find Doctors',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorValues.foreground,
          ),
        ),
        backgroundColor: ColorValues.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: ColorValues.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: ColorValues.background,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorValues.border),
              ),
              child: TextField(
                controller: controller.searchController,
                style: GoogleFonts.poppins(fontSize: 14, color: ColorValues.foreground),
                decoration: InputDecoration(
                  hintText: 'Search by doctor name or specialty...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: ColorValues.mutedForeground),
                  prefixIcon: const Icon(LucideIcons.search, color: ColorValues.mutedForeground, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: InputBorder.none,
                ),
                onSubmitted: (q) => controller.fetchDoctors(q),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorValues.primary),
                );
              }

              if (controller.doctors.isEmpty) {
                return Center(
                  child: Text(
                    'No doctors found.',
                    style: GoogleFonts.poppins(fontSize: 14, color: ColorValues.mutedForeground),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchDoctors(controller.searchController.text),
                color: ColorValues.primary,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: controller.doctors.length,
                  itemBuilder: (context, index) {
                    final doc = controller.doctors[index];
                    return _buildDoctorCard(context, doc);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ColorValues.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.userRound,
                  color: ColorValues.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: ColorValues.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.specialty,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.primary,
                      ),
                    ),
                    Text(
                      doc.hospital,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doc.bio != null && doc.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              doc.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: ColorValues.mutedForeground,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: doc.consultationStatus == 'pending'
                  ? null
                  : () => _showConsultationDialog(context, doc),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValues.primary,
                foregroundColor: ColorValues.primaryForeground,
                disabledBackgroundColor: ColorValues.muted,
                disabledForegroundColor: ColorValues.mutedForeground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                doc.consultationStatus == 'pending'
                    ? 'Consultation Requested'
                    : 'Request Consultation',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConsultationDialog(BuildContext context, Doctor doc) {
    final notesCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Consultation',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Send a consultation inquiry to ${doc.name}.',
                style: GoogleFonts.poppins(fontSize: 12.5, color: ColorValues.mutedForeground),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Notes for doctor (e.g. current symptoms)...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: ColorValues.mutedForeground),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ColorValues.border),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
