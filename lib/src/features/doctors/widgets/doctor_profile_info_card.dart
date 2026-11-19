import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';

class DoctorProfileInfoCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileInfoCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                doctor.bio ??
                    '${doctor.name} is a specialist in ${doctor.specialty} practicing at ${doctor.hospital}. Dedicated to assisting patients with therapy planning, healthy lifestyle adherence, and routine clinical monitoring.',
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
    );
  }
}

