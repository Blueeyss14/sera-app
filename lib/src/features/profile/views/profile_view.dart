import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/plan_history_dialog.dart';
import '../controllers/profile_controller.dart';
import 'activity_metric_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController controller = Get.find<ProfileController>();
  int _selectedTabIndex = 0;
  String? _selectedMetric;

  String? _selectedFeedbackCategory;
  final TextEditingController _feedbackMessageController = TextEditingController();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();
  bool _hasProfileChanges = false;
  bool _isSavingProfile = false;
  String? _lastSyncedPatientKey;

  final List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void dispose() {
    _feedbackMessageController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  void _syncControllersWithPatient(Patient? patient) {
    final key = '${patient?.id}_${patient?.name}_${patient?.birthDate}_${patient?.phone}_${patient?.guardianName}_${patient?.guardianPhone}';
    if (_lastSyncedPatientKey != key && !_hasProfileChanges) {
      _lastSyncedPatientKey = key;
      _fullNameController.text = patient?.name.isNotEmpty == true ? patient!.name : (controller.user?.name ?? '');
      _ageController.text = _extractAgeNumber(patient?.birthDate);
      _phoneController.text = patient?.phone.isNotEmpty == true ? patient!.phone : (controller.user?.phone ?? '');
      _guardianNameController.text = patient?.guardianName ?? '';
      _guardianPhoneController.text = patient?.guardianPhone ?? '';
    }
  }

  void _onFieldChanged() {
    final patient = controller.patient.value;
    final originalName = patient?.name.isNotEmpty == true ? patient!.name : (controller.user?.name ?? '');
    final originalAge = _extractAgeNumber(patient?.birthDate);
    final originalPhone = patient?.phone.isNotEmpty == true ? patient!.phone : (controller.user?.phone ?? '');
    final originalGuardianName = patient?.guardianName ?? '';
    final originalGuardianPhone = patient?.guardianPhone ?? '';

    final changed = _fullNameController.text.trim() != originalName.trim() ||
        _ageController.text.trim() != originalAge.trim() ||
        _phoneController.text.trim() != originalPhone.trim() ||
        _guardianNameController.text.trim() != originalGuardianName.trim() ||
        _guardianPhoneController.text.trim() != originalGuardianPhone.trim();

    if (_hasProfileChanges != changed) {
      setState(() {
        _hasProfileChanges = changed;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    final patient = controller.patient.value;
    final name = _fullNameController.text.trim();
    final ageStr = _ageController.text.trim();
    final phone = _phoneController.text.trim();
    final guardianName = _guardianNameController.text.trim();
    final guardianPhone = _guardianPhoneController.text.trim();

    String? newBirthDate = patient?.birthDate;
    final ageNum = int.tryParse(ageStr);
    if (ageNum != null && ageNum > 0) {
      final birthYear = DateTime.now().year - ageNum;
      newBirthDate = '$birthYear-01-01';
    }

    setState(() => _isSavingProfile = true);
    await controller.updatePersonalInfo(
      name: name,
      birthDate: newBirthDate,
      phone: phone,
      guardianName: guardianName,
      guardianPhone: guardianPhone,
    );

    _lastSyncedPatientKey = null;

    if (!mounted) return;

    setState(() {
      _isSavingProfile = false;
      _hasProfileChanges = false;
    });

    FocusScope.of(context).unfocus();

    Get.snackbar(
      'Profile Updated',
      'Personal information has been saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF0F172A),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'P';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _extractAgeNumber(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return '';
    try {
      final birth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age > 0 ? '$age' : '';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr);
      return '${parsed.day} ${_monthNames[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr);
      final hourStr = parsed.hour.toString().padLeft(2, '0');
      final minuteStr = parsed.minute.toString().padLeft(2, '0');
      return '${parsed.day} ${_monthNames[parsed.month - 1]} ${parsed.year}, $hourStr:$minuteStr';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDayMonth(DateTime dt) {
    const fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = fullDays[dt.weekday - 1];
    return '$dayName, ${dt.day} ${_monthNames[dt.month - 1]}';
  }

  MetricTrend? _getInitialTrendForMetric(String metric) {
    final trends = controller.wearableTrends.value;
    if (trends == null) return null;
    switch (metric) {
      case 'steps':
        return trends.steps;
      case 'heart-rate':
        return trends.heartRate;
      case 'sleep':
        return trends.sleep;
      case 'spo2':
        return trends.spo2;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedMetric == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedMetric != null) {
          setState(() => _selectedMetric = null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _selectedMetric != null
              ? ActivityMetricView(
                  metric: _selectedMetric!,
                  deviceName: controller.wearable.value?.deviceName ?? '',
                  initialTrend: _getInitialTrendForMetric(_selectedMetric!),
                  onBack: () => setState(() => _selectedMetric = null),
                )
              : Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: ColorValues.primary),
                    );
                  }

                  final patient = controller.patient.value;
                  final doctor = controller.assignedDoctor.value;
                  final wearable = controller.wearable.value;
                  final daily = controller.dailyWearable.value;
                  final trends = controller.wearableTrends.value;
                  final adherence = controller.adherence.value;
                  final feedbacks = controller.feedbacks;
                  final plans = controller.plans;

                  return RefreshIndicator(
                    onRefresh: controller.fetchProfile,
                    color: ColorValues.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                          _buildSidebarCard(patient),
                          const SizedBox(height: 16),
                          _buildContentCard(patient, doctor, wearable, daily, trends, adherence, feedbacks, plans),
                        ],
                      ),
                    ),
                  );
                }),
        ),
      ),
    );
  }

  Widget _buildSidebarCard(Patient? patient) {
    final name = patient?.name ?? controller.user?.name ?? 'User';
    final mrn = patient?.mrn ?? '-';
    final isUnlinked = mrn.trim().isEmpty ||
        mrn == '-' ||
        mrn.trim().toUpperCase() == 'UNLINKED' ||
        mrn.trim().toLowerCase() == 'null';

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ColorValues.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(name),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.foreground,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlinked ? 'Unlinked' : mrn,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSidebarMenuItem(
            sectionIndex: 0,
            label: 'Personal Information',
            icon: LucideIcons.userRound,
          ),
          const SizedBox(height: 4),
          _buildSidebarMenuItem(
            sectionIndex: 1,
            label: 'Activity',
            icon: LucideIcons.lineChart,
          ),
          const SizedBox(height: 4),
          _buildSidebarMenuItem(
            sectionIndex: 2,
            label: 'Care Plan History',
            icon: LucideIcons.history,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: ColorValues.border),
          const SizedBox(height: 8),
          InkWell(
            onTap: controller.signOut,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(LucideIcons.logOut, size: 16, color: ColorValues.destructive),
                  const SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.destructive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem({
    required int sectionIndex,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == sectionIndex;

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = sectionIndex),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? ColorValues.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? ColorValues.primary : ColorValues.mutedForeground,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? ColorValues.primary : ColorValues.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(
    Patient? patient,
    Doctor? doctor,
    WearableStatus? wearable,
    DailyWearableData? daily,
    WearableDayTrends? trends,
    AdherenceMetricsResponse? adherence,
    List<FeedbackEntry> feedbacks,
    List<CarePlan> plans,
  ) {
    String sectionTitle = 'Personal Information';
    if (_selectedTabIndex == 1) sectionTitle = 'Activity';
    if (_selectedTabIndex == 2) sectionTitle = 'Care Plan History';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: ColorValues.border),
          const SizedBox(height: 20),
          if (_selectedTabIndex == 0)
            _buildAccountPanel(patient, doctor)
          else if (_selectedTabIndex == 1)
            _buildActivitySection(patient, wearable, daily, trends, adherence, feedbacks)
          else
            _buildHistoryPanel(plans),
        ],
      ),
    );
  }

  Widget _buildAccountPanel(Patient? patient, Doctor? doctor) {
    _syncControllersWithPatient(patient);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldGroup(
          title: 'Identity',
          fields: [
            _buildEditableField(
              label: 'Full Name',
              controller: _fullNameController,
              hintText: 'Enter full name',
              onChanged: _onFieldChanged,
            ),
            _buildEditableField(
              label: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
              hintText: 'Enter age',
              suffixText: 'years',
              onChanged: _onFieldChanged,
            ),
            _buildEditableField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: 'Enter phone number',
              onChanged: _onFieldChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFieldGroup(
          title: 'Guardian',
          fields: [
            _buildEditableField(
              label: 'Guardian Name',
              controller: _guardianNameController,
              hintText: 'Enter guardian name',
              onChanged: _onFieldChanged,
            ),
            _buildEditableField(
              label: 'Guardian Phone',
              controller: _guardianPhoneController,
              keyboardType: TextInputType.phone,
              hintText: 'Enter guardian phone',
              onChanged: _onFieldChanged,
            ),
          ],
        ),
        if (patient?.allergies.isNotEmpty == true && !patient!.allergies.contains('None')) ...[
          const SizedBox(height: 24),
          _buildFieldGroup(
            title: 'Health',
            fields: [
              _buildReadOnlyField(
                label: 'Allergies',
                value: patient.allergies.join(', '),
              ),
            ],
          ),
        ],
        if (_hasProfileChanges) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSavingProfile ? null : _handleSaveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValues.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSavingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? suffixText,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (_) => onChanged(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: ColorValues.foreground,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: ColorValues.mutedForeground.withValues(alpha: 0.5),
              ),
              suffixText: suffixText,
              suffixStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorValues.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGroup({required String title, required List<Widget> fields}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorValues.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        ...fields,
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorValues.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(
    Patient? patient,
    WearableStatus? wearable,
    DailyWearableData? daily,
    WearableDayTrends? trends,
    AdherenceMetricsResponse? adherence,
    List<FeedbackEntry> feedbacks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adherence, smartwatch data, and your reports to the doctor.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Adherence Rate',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Last 7 days. Behavioral data, not an indicator of recovery.',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
        const SizedBox(height: 14),
        _buildAdherenceLineChart(adherence),
        const SizedBox(height: 14),
        _buildAdherenceSummaryCards(adherence),
        const SizedBox(height: 32),
        Text(
          'Smartwatch Data',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Steps, heart rate, sleep, and blood oxygen (SpO2).',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
        const SizedBox(height: 14),
        if (wearable != null && wearable.isConnected)
          _buildConnectedWearableSection(wearable, daily, trends)
        else
          _buildWearableConnectPrompt(),
        const SizedBox(height: 32),
        Text(
          'Report Issue or Symptom',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 14),
        _buildFeedbackForm(),
        const SizedBox(height: 32),
        Text(
          'My Reports',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 14),
        _buildFeedbackList(feedbacks),
      ],
    );
  }

  Widget _buildAdherenceLineChart(AdherenceMetricsResponse? adherence) {
    final points = adherence?.trend ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorValues.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _AdherenceWebChartPainter(
                points: points,
                dayNames: _dayNames,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Medication',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorValues.mutedForeground,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Activity',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorValues.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceSummaryCards(AdherenceMetricsResponse? adherence) {
    final summary = adherence?.summary;
    final medAvg = summary?.medicationAverage ?? 0;
    final actAvg = summary?.activityAverage ?? 0;
    final lowest = summary?.lowest;

    String lowestText = 'No data';
    if (lowest != null) {
      final kindStr = lowest['kind'] == 'medication' ? 'Medication' : 'Activity';
      final percentStr = '${lowest['percent'] ?? 0}%';
      String dateStr = '';
      if (lowest['date'] != null) {
        try {
          final dt = DateTime.parse(lowest['date'].toString());
          dateStr = ' · ${_formatDayMonth(dt)}';
        } catch (_) {}
      }
      lowestText = '$kindStr $percentStr$dateStr';
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Medication Adherence',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$medAvg%',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Activity Adherence',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$actAvg%',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lowest Performance',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lowestText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedWearableSection(
    WearableStatus wearable,
    DailyWearableData? daily,
    WearableDayTrends? trends,
  ) {
    final stepsVal = trends?.steps?.headline.value ?? (daily != null ? '${daily.steps}' : '1,250');
    final stepsUnit = 'steps';

    final heartRateVal = trends?.heartRate?.headline.value ?? (daily != null ? '${daily.heartRateResting}' : '82');
    final heartRateUnit = 'bpm';

    String sleepVal = trends?.sleep?.headline.value ?? '';
    if (sleepVal.isNotEmpty) {
      sleepVal = sleepVal.replaceAll(' j', 'h').replaceAll(' mnt', 'm').replaceAll('j', 'h').replaceAll('mnt', 'm');
    } else if (daily != null) {
      sleepVal = '${daily.sleepMinutes ~/ 60}h ${daily.sleepMinutes % 60}m';
    } else {
      sleepVal = '-';
    }

    final spo2Val = trends?.spo2?.headline.value ?? (daily != null ? '${daily.spo2}' : '-');
    final spo2Unit = '%';

    final connectedDateStr = wearable.connectedAt != null ? _formatDateTime(wearable.connectedAt) : '-';
    final syncDateStr = wearable.lastSyncAt != null ? _formatDateTime(wearable.lastSyncAt) : '-';

    final hrPoints = trends?.heartRate?.points.where((p) => p.value != null).map((p) => p.value!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.94,
          children: [
            _buildWebMetricCard(
              icon: LucideIcons.footprints,
              iconBgColor: ColorValues.primary.withValues(alpha: 0.1),
              iconColor: ColorValues.primary,
              title: 'Steps',
              value: stepsVal,
              unit: stepsUnit,
              chartWidget: _buildStepsMiniChart(trends?.steps?.points),
              bottomLabel: 'Steps',
              onTap: () => setState(() => _selectedMetric = 'steps'),
            ),
            _buildWebMetricCard(
              icon: LucideIcons.heartPulse,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Heart Rate',
              value: heartRateVal,
              unit: heartRateUnit,
              chartWidget: SizedBox(
                width: double.infinity,
                height: 36,
                child: CustomPaint(
                  painter: _HeartRateMiniChartPainter(values: hrPoints),
                ),
              ),
              bottomLabel: 'Last updated',
              onTap: () => setState(() => _selectedMetric = 'heart-rate'),
            ),
            _buildWebMetricCard(
              icon: LucideIcons.moon,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Sleep',
              value: sleepVal,
              unit: '',
              chartWidget: _buildSleepMiniChart(trends?.sleep?.points),
              bottomLabel: 'Night sleep',
              onTap: () => setState(() => _selectedMetric = 'sleep'),
            ),
            _buildWebMetricCard(
              icon: LucideIcons.droplets,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: 'SpO₂',
              value: spo2Val,
              unit: spo2Unit,
              chartWidget: _buildSpo2MiniChart(trends?.spo2?.points),
              bottomLabel: 'Average SpO₂',
              onTap: () => setState(() => _selectedMetric = 'spo2'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorValues.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorValues.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.watch, color: ColorValues.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                wearable.deviceName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: ColorValues.foreground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Connected',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last sync: $syncDateStr · Connected since: $connectedDateStr',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: ColorValues.mutedForeground,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(() {
                    final syncing = controller.isSyncing.value;
                    return OutlinedButton.icon(
                      onPressed: syncing ? null : controller.syncWearable,
                      icon: syncing
                          ? const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.foreground),
                            )
                          : const Icon(LucideIcons.refreshCw, size: 14, color: ColorValues.foreground),
                      label: Text(
                        'Sync Now',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: ColorValues.foreground,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ColorValues.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      ),
                    );
                  }),
                  const SizedBox(width: 14),
                  InkWell(
                    onTap: _showDisconnectDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Text(
                        'Disconnect',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ColorValues.destructive,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebMetricCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required Widget chartWidget,
    required String bottomLabel,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorValues.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 14, color: ColorValues.mutedForeground),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: chartWidget,
            ),
            Text(
              bottomLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsMiniChart(List<TrendPoint>? points) {
    final nonNull = points?.where((p) => p.value != null && p.value! > 0).map((p) => p.value!.toDouble()).toList() ?? [];

    List<double> barHeights;
    if (nonNull.isNotEmpty) {
      final maxVal = nonNull.reduce(math.max);
      barHeights = nonNull.map((v) {
        if (maxVal == 0) return 16.0;
        return (v / maxVal * 20.0) + 16.0;
      }).toList();
    } else {
      barHeights = [16.0, 26.0, 36.0];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: barHeights.take(5).map((h) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 10,
          height: h.clamp(10.0, 36.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSleepMiniChart(List<TrendPoint>? points) {
    final stageColors = {
      'deep': const Color(0xFF3B82F6),
      'light': const Color(0xFF06B6D4),
      'rem': const Color(0xFF818CF8),
      'awake': const Color(0xFFF59E0B),
    };

    final defaultHeights = [16.0, 36.0, 20.0, 8.0];
    final defaultColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF06B6D4),
      const Color(0xFF818CF8),
      const Color(0xFFF59E0B),
    ];

    if (points != null && points.isNotEmpty) {
      final maxVal = points.map((p) => p.value?.toDouble() ?? 0.0).fold(0.0, math.max);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final val = p.value?.toDouble() ?? 0.0;
          final h = maxVal > 0 ? ((val / maxVal) * 26.0 + 10.0) : 16.0;
          final color = stageColors[p.key] ?? const Color(0xFF3B82F6);
          return Container(
            margin: const EdgeInsets.only(right: 6),
            width: 12,
            height: h.clamp(6.0, 36.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 12,
          height: defaultHeights[i],
          decoration: BoxDecoration(
            color: defaultColors[i],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildSpo2MiniChart(List<TrendPoint>? points) {
    final count = (points != null && points.isNotEmpty) ? points.length : 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(count.clamp(1, 5), (i) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 12,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildWearableConnectPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: ColorValues.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.watch, color: ColorValues.primary, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            'Smartwatch Not Connected',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connect your smartwatch to monitor daily steps, heart rate, sleep duration, and SpO2 readings.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showConnectDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorValues.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Connect Smartwatch',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect Smartwatch',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter smartwatch code to connect device.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: ColorValues.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: ColorValues.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Smartwatch Code',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Code',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: ColorValues.mutedForeground.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ColorValues.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Obx(() {
                  final isConnecting = controller.isConnectingWearable.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isConnecting
                          ? null
                          : () async {
                              final text = nameCtrl.text.trim();
                              if (text.isEmpty) return;
                              final success = await controller.connectWearable(text);
                              if (ctx.mounted && success) {
                                Navigator.of(ctx).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorValues.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isConnecting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Connecting...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Connect',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorValues.foreground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.foreground,
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

  void _showDisconnectDialog() {
    final wearable = controller.wearable.value;
    final deviceName = wearable?.deviceName ?? '';
    final connectedDateStr = wearable?.connectedAt != null ? _formatDateTime(wearable!.connectedAt) : '-';
    final syncDateStr = wearable?.lastSyncAt != null ? _formatDateTime(wearable!.lastSyncAt) : '-';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disconnect Smartwatch?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Are you sure you want to disconnect this smartwatch?',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: ColorValues.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          LucideIcons.x,
                          size: 18,
                          color: ColorValues.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.watch,
                            size: 16,
                            color: ColorValues.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              deviceName,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorValues.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '● Connected',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connected Since',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400,
                                    color: ColorValues.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  connectedDateStr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: ColorValues.foreground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Sync',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400,
                                    color: ColorValues.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  syncDateStr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: ColorValues.foreground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final isDisconnecting = controller.isDisconnecting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isDisconnecting
                          ? null
                          : () async {
                              await controller.disconnectWearable();
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isDisconnecting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Disconnecting...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Disconnect',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.foreground,
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

  Widget _buildFeedbackForm() {
    final categories = [
      {'id': 'side-effect', 'label': 'Side Effect'},
      {'id': 'symptom', 'label': 'Symptom'},
      {'id': 'obstacle', 'label': 'Routine Obstacle'},
      {'id': 'other', 'label': 'Other'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Category',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorValues.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFeedbackCategory,
              hint: Text(
                'Select report category',
                style: GoogleFonts.poppins(fontSize: 13, color: ColorValues.mutedForeground),
              ),
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: ColorValues.mutedForeground),
              items: categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['id'],
                  child: Text(
                    cat['label']!,
                    style: GoogleFonts.poppins(fontSize: 13, color: ColorValues.foreground),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedFeedbackCategory = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Describe your issue or symptom',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorValues.border),
          ),
          child: TextField(
            controller: _feedbackMessageController,
            maxLines: 4,
            style: GoogleFonts.poppins(fontSize: 13, color: ColorValues.foreground),
            decoration: InputDecoration(
              hintText: 'e.g. Dizziness after taking morning medication',
              hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: ColorValues.mutedForeground),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final sending = controller.isSendingFeedback.value;
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (_selectedFeedbackCategory == null) {
                        Get.snackbar(
                          'Category Required',
                          'Please select a report category first.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 14,
                        );
                        return;
                      }
                      final msg = _feedbackMessageController.text.trim();
                      if (msg.isEmpty) {
                        Get.snackbar(
                          'Message Required',
                          'Please describe your issue or symptom.',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 14,
                        );
                        return;
                      }
                      final ok = await controller.sendFeedback(_selectedFeedbackCategory!, msg);
                      if (ok) {
                        _feedbackMessageController.clear();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValues.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Send to Doctor',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeedbackList(List<FeedbackEntry> feedbacks) {
    if (feedbacks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'You have not submitted any reports yet.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedbacks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final item = feedbacks[index];
        final isResolved = item.status == 'resolved';

        String categoryLabel = 'Other';
        if (item.category == 'side-effect' || item.category == 'side_effect') {
          categoryLabel = 'Side Effect';
        } else if (item.category == 'symptom') {
          categoryLabel = 'Symptom';
        } else if (item.category == 'obstacle' || item.category == 'schedule_conflict') {
          categoryLabel = 'Routine Obstacle';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorValues.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorValues.muted.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categoryLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isResolved ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isResolved ? 'Reviewed' : 'Pending Review',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isResolved ? const Color(0xFF047857) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(item.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: ColorValues.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.foreground,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryPanel(List<CarePlan> plans) {
    if (plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No care plan history available.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: ColorValues.border),
      itemBuilder: (ctx, index) {
        final plan = plans[index];
        final isActive = plan.status == 'active';

        return InkWell(
          onTap: () => showPlanHistoryDialog(context, plan: plan),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version ${plan.version}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorValues.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.confirmedAt != null
                            ? 'Confirmed ${_formatDate(plan.confirmedAt)}'
                            : 'Pending confirmation',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ColorValues.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? ColorValues.primary.withValues(alpha: 0.1) : ColorValues.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? ColorValues.primary.withValues(alpha: 0.3) : ColorValues.border,
                    ),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Superseded',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive ? ColorValues.primary : ColorValues.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronRight, size: 16, color: ColorValues.mutedForeground),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdherenceWebChartPainter extends CustomPainter {
  final List<AdherenceTrendPoint> points;
  final List<String> dayNames;

  _AdherenceWebChartPainter({required this.points, required this.dayNames});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final medPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final actPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaintMed = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderMed = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double leftMargin = 38.0;
    const double bottomMargin = 22.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin;

    final textStyle = GoogleFonts.poppins(
      fontSize: 11,
      color: const Color(0xFF64748B),
      fontWeight: FontWeight.w400,
    );

    final yTicks = [0, 25, 50, 75, 100];
    for (final tick in yTicks) {
      final y = chartHeight - (tick / 100.0 * chartHeight);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(text: '$tick%', style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    final displayPoints = points.isNotEmpty
        ? points
        : [
            AdherenceTrendPoint(date: '2026-11-11', medication: 100, activity: 100),
            AdherenceTrendPoint(date: '2026-11-12', medication: 100, activity: 100),
            AdherenceTrendPoint(date: '2026-11-13', medication: 100, activity: 0),
            AdherenceTrendPoint(date: '2026-11-14', medication: 100, activity: 100),
            AdherenceTrendPoint(date: '2026-11-15', medication: 0, activity: 100),
            AdherenceTrendPoint(date: '2026-11-16', medication: 100, activity: 100),
            AdherenceTrendPoint(date: '2026-11-17', medication: 100, activity: 100),
          ];

    final n = displayPoints.length;
    if (n < 2) return;

    final stepX = chartWidth / (n - 1);

    final medPath = Path();
    final actPath = Path();

    for (int i = 0; i < n; i++) {
      final x = leftMargin + i * stepX;
      final medVal = (displayPoints[i].medication ?? 100).clamp(0, 100);
      final actVal = (displayPoints[i].activity ?? 100).clamp(0, 100);

      final medY = chartHeight - (medVal / 100.0 * chartHeight);
      final actY = chartHeight - (actVal / 100.0 * chartHeight);

      if (i == 0) {
        medPath.moveTo(x, medY);
        actPath.moveTo(x, actY);
      } else {
        medPath.lineTo(x, medY);
        actPath.lineTo(x, actY);
      }

      String dayLabel = '';
      try {
        final parsed = DateTime.parse(displayPoints[i].date);
        dayLabel = dayNames[parsed.weekday - 1];
      } catch (_) {
        dayLabel = 'D${i + 1}';
      }

      final xTextSpan = TextSpan(text: dayLabel, style: textStyle);
      final xPainter = TextPainter(text: xTextSpan, textDirection: TextDirection.ltr);
      xPainter.layout();
      xPainter.paint(canvas, Offset(x - xPainter.width / 2, chartHeight + 6));
    }

    canvas.drawPath(medPath, medPaint);
    _drawDashedPath(canvas, actPath, actPaint);

    for (int i = 0; i < n; i++) {
      final x = leftMargin + i * stepX;
      final medVal = (displayPoints[i].medication ?? 100).clamp(0, 100);
      final actVal = (displayPoints[i].activity ?? 100).clamp(0, 100);

      final medY = chartHeight - (medVal / 100.0 * chartHeight);
      final actY = chartHeight - (actVal / 100.0 * chartHeight);

      canvas.drawCircle(Offset(x, medY), 3.5, dotPaintMed);
      canvas.drawCircle(Offset(x, medY), 3.5, dotBorderMed);

      canvas.drawCircle(Offset(x, actY), 3.5, dotPaintMed);
      canvas.drawCircle(Offset(x, actY), 3.5, dotBorderMed);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.5;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdherenceWebChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _HeartRateMiniChartPainter extends CustomPainter {
  final List<num>? values;

  _HeartRateMiniChartPainter({this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final validValues = values?.where((v) => v > 0).toList() ?? [];

    final linePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final fillPath = Path();

    if (validValues.length >= 2) {
      final minVal = validValues.reduce(math.min).toDouble();
      final maxVal = validValues.reduce(math.max).toDouble();
      final range = (maxVal - minVal) > 0 ? (maxVal - minVal) : 1.0;

      final count = validValues.length;
      final stepX = (size.width * 0.75) / (count - 1);

      final pts = <Offset>[];
      for (int i = 0; i < count; i++) {
        final x = i * stepX;
        final normalized = (validValues[i] - minVal) / range;
        final y = size.height * 0.75 - (normalized * size.height * 0.55);
        pts.add(Offset(x, y));
      }

      path.moveTo(pts[0].dx, pts[0].dy);
      fillPath.moveTo(pts[0].dx, pts[0].dy);

      for (int i = 0; i < pts.length - 1; i++) {
        final p0 = pts[i];
        final p1 = pts[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(pts.last.dx, size.height);
      fillPath.lineTo(pts.first.dx, size.height);
      fillPath.close();
    } else {
      final startX = 0.0;
      final startY = size.height * 0.7;
      final endX = size.width * 0.75;
      final endY = size.height * 0.25;

      path.moveTo(startX, startY);
      path.cubicTo(
        size.width * 0.35,
        startY,
        size.width * 0.45,
        endY,
        endX,
        endY,
      );

      fillPath.moveTo(startX, startY);
      fillPath.cubicTo(
        size.width * 0.35,
        startY,
        size.width * 0.45,
        endY,
        endX,
        endY,
      );
      fillPath.lineTo(endX, size.height);
      fillPath.lineTo(startX, size.height);
      fillPath.close();
    }

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x4DEF4444),
          Color(0x00EF4444),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartRateMiniChartPainter oldDelegate) => true;
}
