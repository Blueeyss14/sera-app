import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';

class BookingSuccessSheet extends StatelessWidget {
  final Doctor doctor;
  final DateTime scheduledDate;
  final String scheduledTime;

  const BookingSuccessSheet({
    super.key,
    required this.doctor,
    required this.scheduledDate,
    required this.scheduledTime,
  });

  static Future<void> show({
    required BuildContext context,
    required Doctor doctor,
    required DateTime scheduledDate,
    required String scheduledTime,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingSuccessSheet(
        doctor: doctor,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorValues.success.withValues(alpha: 0.12),
            ),
            child: const Icon(
              LucideIcons.circleCheck,
              size: 32,
              color: ColorValues.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Request Sent!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your consultation request with ${doctor.name} has been submitted with Pending status.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ColorValues.mutedForeground,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorValues.muted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorValues.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scheduled Date',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(scheduledDate),
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scheduled Time',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                    Text(
                      scheduledTime,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Pending Confirmation',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorValues.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

