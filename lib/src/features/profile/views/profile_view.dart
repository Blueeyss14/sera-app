import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        title: Text(
          'Patient Profile',
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorValues.primary),
          );
        }

        final patient = controller.patient.value;
        final wearable = controller.wearable.value;
        final history = controller.history;

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          color: ColorValues.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (patient != null) _buildPatientCard(patient),
                const SizedBox(height: 20),
                _buildSmartwatchCard(wearable),
                const SizedBox(height: 24),
                Text(
                  'Medical History',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorValues.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorValues.border),
                    ),
                    child: Text(
                      'No recorded health history.',
                      style: GoogleFonts.poppins(fontSize: 13, color: ColorValues.mutedForeground),
                    ),
                  )
                else
                  ...history.map((h) => _buildHistoryItem(h)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: controller.signOut,
                    icon: const Icon(LucideIcons.logOut, color: ColorValues.destructive, size: 18),
                    label: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.destructive,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ColorValues.destructive, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: ColorValues.primaryLight,
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0] : 'P',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ColorValues.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ColorValues.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorValues.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            patient.mrn,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.secondaryForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          patient.gender.capitalizeFirst ?? '',
                          style: GoogleFonts.poppins(fontSize: 12, color: ColorValues.mutedForeground),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: ColorValues.border),
          const SizedBox(height: 12),
          _buildInfoRow('Diagnosis', patient.primaryDiagnosis ?? 'None'),
          const SizedBox(height: 8),
          _buildInfoRow('Phone', patient.phone),
          const SizedBox(height: 8),
          _buildInfoRow('Address', patient.address ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: ColorValues.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorValues.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartwatchCard(WearableStatus? wearable) {
    final isConnected = wearable?.isConnected == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorValues.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isConnected ? ColorValues.successLight : ColorValues.muted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.watch,
                  color: isConnected ? ColorValues.success : ColorValues.mutedForeground,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wearable?.deviceName ?? 'Smartwatch',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorValues.foreground,
                      ),
                    ),
                    Text(
                      isConnected ? 'Connected & Monitoring' : 'Disconnected',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isConnected ? ColorValues.success : ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                Obx(() => controller.isSyncing.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.primary),
                      )
                    : IconButton(
                        onPressed: controller.syncWearable,
                        icon: const Icon(LucideIcons.refreshCw, color: ColorValues.primary, size: 18),
                        tooltip: 'Sync Data',
                      )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HealthHistoryEntry entry) {
    IconData icon;
    Color color;

    switch (entry.type) {
      case 'diagnosis':
        icon = LucideIcons.stethoscope;
        color = ColorValues.destructive;
        break;
      case 'lab':
        icon = LucideIcons.flaskConical;
        color = ColorValues.primary;
        break;
      case 'visit':
        icon = LucideIcons.hospital;
        color = ColorValues.success;
        break;
      default:
        icon = LucideIcons.activity;
        color = ColorValues.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorValues.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorValues.foreground,
                        ),
                      ),
                    ),
                    Text(
                      entry.date.split(' ').first,
                      style: GoogleFonts.poppins(fontSize: 11, color: ColorValues.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.notes,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: ColorValues.mutedForeground,
                    height: 1.4,
                  ),
                ),
                if (entry.value != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorValues.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.value!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.secondaryForeground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
