import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.find<ProfileController>();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ColorValues.foreground,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (patient != null) _buildPatientHeaderCard(patient),
                  const SizedBox(height: 18),
                  _buildTabBar(),
                  const SizedBox(height: 18),
                  if (_selectedTabIndex == 0 && patient != null)
                    _buildPersonalInfoTab(patient)
                  else if (_selectedTabIndex == 1)
                    _buildWearableTab(wearable)
                  else
                    _buildHistoryTab(history),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPatientHeaderCard(Patient patient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorValues.primary,
            ),
            child: Center(
              child: Text(
                patient.name.isNotEmpty ? patient.name[0] : 'P',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MRN: ${patient.mrn} · Born ${patient.birthDate}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.mutedForeground,
                  ),
                ),
                if (patient.primaryDiagnosis != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.activity, size: 12, color: ColorValues.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patient.primaryDiagnosis!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorValues.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Personal Data', 'Activity & Smartwatch', 'Plan History'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorValues.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? ColorValues.primary : ColorValues.mutedForeground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonalInfoTab(Patient patient) {
    final rows = [
      {'label': 'FULL NAME', 'value': patient.name},
      {'label': 'MEDICAL RECORD NUMBER (MRN)', 'value': patient.mrn},
      {'label': 'GENDER', 'value': patient.gender == 'female' ? 'Female' : 'Male'},
      {'label': 'DATE OF BIRTH', 'value': patient.birthDate},
      {'label': 'PHONE NUMBER', 'value': patient.phone},
      if (patient.address != null) {'label': 'RESIDENTIAL ADDRESS', 'value': patient.address!},
      if (patient.primaryDiagnosis != null) {'label': 'PRIMARY DIAGNOSIS', 'value': patient.primaryDiagnosis!},
      if (patient.conditions.isNotEmpty) {'label': 'HEALTH CONDITIONS', 'value': patient.conditions.join(', ')},
      if (patient.allergies.isNotEmpty) {'label': 'ALLERGIES', 'value': patient.allergies.join(', ')},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorValues.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map((r) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.7,
                    color: ColorValues.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r['value']!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.foreground,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWearableTab(WearableStatus? wearable) {
    final isConnected = wearable?.isConnected ?? false;

    return Column(
      children: [
        Container(
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
                      shape: BoxShape.circle,
                      color: isConnected
                          ? ColorValues.success.withValues(alpha: 0.12)
                          : ColorValues.muted,
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
                          wearable?.deviceName ?? 'SERA Health Band Pro',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ColorValues.foreground,
                          ),
                        ),
                        Text(
                          isConnected ? 'Connected & Monitoring' : 'Device Disconnected',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isConnected ? ColorValues.success : ColorValues.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? ColorValues.success.withValues(alpha: 0.15)
                          : ColorValues.muted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isConnected ? 'Active' : 'Offline',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isConnected ? ColorValues.success : ColorValues.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: LucideIcons.heartPulse,
                      label: 'Heart Rate',
                      value: '74 bpm',
                      color: ColorValues.destructive,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      icon: LucideIcons.footprints,
                      label: 'Daily Steps',
                      value: '4,820',
                      color: ColorValues.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: LucideIcons.moon,
                      label: 'Sleep Duration',
                      value: '7.5 hrs',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      icon: LucideIcons.batteryMedium,
                      label: 'Device Battery',
                      value: '88%',
                      color: ColorValues.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: controller.isSyncing.value ? null : controller.syncWearable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorValues.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: controller.isSyncing.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.refreshCw, size: 16),
                  label: Text(
                    controller.isSyncing.value ? 'Syncing...' : 'Sync Smartwatch Now',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<HealthHistoryEntry> history) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: ColorValues.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ColorValues.border),
        ),
        child: Center(
          child: Text(
            'No recorded health history.',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
        ),
      );
    }

    return Column(
      children: history.map((h) {
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorValues.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(LucideIcons.fileText, color: ColorValues.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      h.notes,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      h.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
