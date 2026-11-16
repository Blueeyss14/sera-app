import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/ring_ornament.dart';
import '../controllers/doctors_controller.dart';

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
      _showRequestModal();
    }
  }

  void _showRequestModal() {
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request Consultation',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Send an initial consultation request to ${_doctor.name}.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: ColorValues.mutedForeground,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Notes for doctor (e.g. current health goals, symptoms)...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: ColorValues.mutedForeground,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: ColorValues.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: ColorValues.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);
                      final success = await controller.requestConsultation(
                        _doctor.id,
                        notesCtrl.text.trim().isEmpty ? 'Initial consultation request.' : notesCtrl.text.trim(),
                      );
                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (success) {
                          Get.snackbar(
                            'Sent',
                            'Consultation request sent to ${_doctor.name}.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: ColorValues.card,
                            colorText: ColorValues.foreground,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 16,
                          );
                          _refreshDetail();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorValues.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(LucideIcons.send, size: 16),
                    label: Text(
                      'Send Request',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = _doctor.consultationStatus == 'pending';
    final isApproved = _doctor.consultationStatus == 'approved';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: ColorValues.foreground, size: 20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorValues.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ColorValues.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ColorValues.primary, Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const RingOrnament(),
                        Positioned(
                          top: 14,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Sera Clinician Network',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _doctor.avatarUrl != null
                                    ? Image.network(
                                        _doctor.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => _buildFallbackAvatar(),
                                      )
                                    : _buildFallbackAvatar(),
                              ),
                              _buildActionButton(isPending, isApproved),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctor.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: ColorValues.foreground,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ColorValues.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: ColorValues.primary.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.stethoscope, size: 13, color: ColorValues.primary),
                                    const SizedBox(width: 5),
                                    Text(
                                      _doctor.specialty,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ColorValues.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Specialist at ${_doctor.hospital}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ColorValues.foreground.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 14,
                                runSpacing: 6,
                                children: [
                                  _buildContactChip(LucideIcons.building2, _doctor.hospital),
                                  _buildContactChip(LucideIcons.mail, _doctor.email),
                                  if (_doctor.phone != null)
                                    _buildContactChip(LucideIcons.phone, _doctor.phone!),
                                ],
                              ),
                              if (isPending) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.clock, size: 16, color: Colors.amber),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Your consultation request has been sent and is awaiting confirmation from the doctor in the hospital system.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.amber.shade900,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (isApproved) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ColorValues.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: ColorValues.success.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.circleCheck, size: 16, color: ColorValues.success),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'You are connected with this doctor. The doctor can manage your Care Plan and monitor your health adherence routines.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: ColorValues.success,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ColorValues.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ColorValues.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, size: 18, color: ColorValues.primary),
                      const SizedBox(width: 8),
                      Text(
                        'About Doctor',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorValues.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _doctor.bio ??
                        '${_doctor.name} is a specialist in ${_doctor.specialty} practicing at ${_doctor.hospital}. Dedicated to assisting patients with therapy planning, healthy lifestyle adherence, and routine clinical monitoring.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.foreground.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ColorValues.card,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ColorValues.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.heartPulse, size: 18, color: ColorValues.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Sera Digital Care & Monitoring',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ColorValues.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColorValues.muted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorValues.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Care Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: ColorValues.foreground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'The doctor designs your medication schedule, physical activities, and nutritional targets directly linked to your app.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorValues.mutedForeground,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColorValues.muted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorValues.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Adherence Evaluation',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: ColorValues.foreground,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your daily progress is monitored by the doctor to determine dosage adjustments or next consultation follow-ups.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorValues.mutedForeground,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: ColorValues.primary.withValues(alpha: 0.08),
      child: Center(
        child: Image.asset(
          ImageAssets.seraGreeting,
          width: 56,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: ColorValues.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isPending, bool isApproved) {
    if (_isLoading) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.primary),
      );
    }

    if (isApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ColorValues.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorValues.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleCheck, size: 14, color: ColorValues.success),
            const SizedBox(width: 6),
            Text(
              'Consulted',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorValues.success,
              ),
            ),
          ],
        ),
      );
    }

    if (isPending) {
      return OutlinedButton.icon(
        onPressed: _handleAction,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: ColorValues.destructive),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        icon: const Icon(LucideIcons.x, size: 14, color: ColorValues.destructive),
        label: Text(
          'Cancel Request',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorValues.destructive,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _handleAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: const Icon(LucideIcons.send, size: 14),
      label: Text(
        'Request Consultation',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
