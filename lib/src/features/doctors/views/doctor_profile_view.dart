import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/doctors_controller.dart';
import '../widgets/doctor_profile_header.dart';
import '../widgets/doctor_profile_info_card.dart';
import 'doctor_schedule_view.dart';

class DoctorProfileView extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileView({super.key, required this.doctor});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  late Doctor _doctor;
  final controller = Get.find<DoctorsController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final updated = await controller.getDoctorDetail(_doctor.id);
    if (updated != null && mounted) {
      setState(() {
        _doctor = updated;
      });
    }
  }

  Future<void> _handleAction() async {
    if (_doctor.consultationStatus == 'approved') return;

    if (_doctor.consultationStatus == 'pending' && _doctor.activeRequestId != null) {
      setState(() => _isLoading = true);
      final success = await controller.cancelConsultation(_doctor.activeRequestId!);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Get.snackbar(
            'Canceled',
            'Consultation request has been canceled.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ColorValues.card,
            colorText: ColorValues.foreground,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
          );
          _refreshDetail();
        }
      }
    } else {
      _openScheduleBooking();
    }
  }

  void _openScheduleBooking() async {
    await Get.to(() => DoctorScheduleView(doctor: _doctor));
    _refreshDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: ColorValues.foreground, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Back to Find Doctors',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorValues.mutedForeground,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            DoctorProfileHeader(
              doctor: _doctor,
              isLoading: _isLoading,
              onAction: _handleAction,
              onBook: _openScheduleBooking,
            ),
            const SizedBox(height: 20),
            DoctorProfileInfoCard(doctor: _doctor),
          ],
        ),
      ),
    );
  }
}
