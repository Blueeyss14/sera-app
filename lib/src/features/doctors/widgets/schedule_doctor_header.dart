import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';

class ScheduleDoctorHeader extends StatelessWidget {
  final Doctor doctor;

  const ScheduleDoctorHeader({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ColorValues.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorValues.border.withValues(alpha: 0.6)),
            ),
            clipBehavior: Clip.antiAlias,
            child: doctor.avatarUrl != null
                ? Image.network(
                    doctor.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildAvatarFallback(),
                  )
                : _buildAvatarFallback(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(LucideIcons.stethoscope, size: 12, color: ColorValues.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.specialty,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorValues.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(LucideIcons.building2, size: 12, color: ColorValues.mutedForeground),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.hospital,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: ColorValues.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Image.asset(
        ImageAssets.seraGreeting,
        width: 38,
        fit: BoxFit.contain,
      ),
    );
  }
}

