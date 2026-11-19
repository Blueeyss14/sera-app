import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../controllers/doctors_controller.dart';
import '../widgets/booking_success_sheet.dart';
import '../widgets/schedule_date_picker.dart';
import '../widgets/schedule_doctor_header.dart';
import '../widgets/schedule_time_slots.dart';

class DoctorScheduleView extends StatefulWidget {
  final Doctor doctor;

  const DoctorScheduleView({super.key, required this.doctor});

  @override
  State<DoctorScheduleView> createState() => _DoctorScheduleViewState();
}

class _DoctorScheduleViewState extends State<DoctorScheduleView> {
  final controller = Get.find<DoctorsController>();
  final TextEditingController _notesController = TextEditingController();

  late List<DateTime> _availableDates;
  late DateTime _selectedDate;
  String? _selectedTime;

  bool _isLoadingSlots = false;
  bool _isSubmitting = false;
  List<DoctorSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _initDates();
    _fetchSlotsForDate(_selectedDate);
  }

  void _initDates() {
    final now = DateTime.now();
    _availableDates = List.generate(14, (index) {
      return DateTime(now.year, now.month, now.day).add(Duration(days: index + 1));
    });
    _selectedDate = _availableDates.first;
  }

  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _selectedTime = null;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final res = await controller.fetchAvailableSlots(widget.doctor.id, dateStr);

    if (mounted) {
      setState(() {
        _isLoadingSlots = false;
        _slots = res?.slots ?? [];
      });
    }
  }

  Future<void> _submitConsultation() async {
    if (_selectedTime == null) {
      Get.snackbar(
        'Time slot required',
        'Please select a consultation time slot before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ColorValues.card,
        colorText: ColorValues.foreground,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    final success = await controller.requestConsultation(
      doctorId: widget.doctor.id,
      scheduledDate: dateStr,
      scheduledTime: _selectedTime,
      notes: notes,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        BookingSuccessSheet.show(
          context: context,
          doctor: widget.doctor,
          scheduledDate: _selectedDate,
          scheduledTime: _selectedTime!,
        );
      } else {
        Get.snackbar(
          'Submission Failed',
          'Unable to submit consultation request. Please try another slot or check your connection.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ColorValues.card,
          colorText: ColorValues.destructive,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
          icon: const Icon(LucideIcons.arrowLeft, color: ColorValues.foreground, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Schedule',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScheduleDoctorHeader(doctor: widget.doctor),
                    const SizedBox(height: 20),
                    ScheduleDatePicker(
                      dates: _availableDates,
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                        _fetchSlotsForDate(date);
                      },
                    ),
                    const SizedBox(height: 24),
                    ScheduleTimeSlots(
                      slots: _slots,
                      selectedTime: _selectedTime,
                      isLoading: _isLoadingSlots,
                      onSlotToggled: (time) {
                        setState(() => _selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 20),
                    _buildNoticeBanner(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consultation Notes',
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide details regarding symptoms or medical background for your attending doctor.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: ColorValues.mutedForeground,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13, color: ColorValues.foreground),
          decoration: InputDecoration(
            hintText: 'e.g., Routine blood pressure follow-up, frequently feeling dizziness in the morning...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              color: ColorValues.mutedForeground.withValues(alpha: 0.7),
            ),
            contentPadding: const EdgeInsets.all(14),
            filled: true,
            fillColor: ColorValues.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ColorValues.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ColorValues.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ColorValues.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorValues.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorValues.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.info,
            size: 16,
            color: ColorValues.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your request will be recorded with Pending status. The doctor will review and either Accept or Decline from the hospital workspace.',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: ColorValues.foreground.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _selectedTime != null && !_isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColorValues.border.withValues(alpha: 0.6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: canSubmit ? _submitConsultation : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorValues.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: ColorValues.primary.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(LucideIcons.calendarCheck, size: 18),
          label: Text(
            _isSubmitting
                ? 'Sending Request...'
                : _selectedTime != null
                    ? 'Submit Consultation ($_selectedTime)'
                    : 'Select Time Slot',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
