import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onViewProfile;
  final VoidCallback onConsult;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onViewProfile,
    required this.onConsult,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = doctor.consultationStatus == 'pending';
    final isApproved = doctor.consultationStatus == 'approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onViewProfile,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ColorValues.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.foreground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.stethoscope,
                                size: 13,
                                color: ColorValues.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  doctor.specialty,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorValues.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.building2,
                                size: 13,
                                color: ColorValues.mutedForeground,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  doctor.hospital,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
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
                if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    doctor.bio!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: ColorValues.border.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.clock, size: 12, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              'Pending Confirmation',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isApproved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorValues.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorValues.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.circleCheck, size: 12, color: ColorValues.success),
                            const SizedBox(width: 5),
                            Text(
                              'Connected',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorValues.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: ColorValues.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: Text(
                          'Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorValues.mutedForeground,
                          ),
                        ),
                      ),
                    if (isPending)
                      OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: ColorValues.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: Text(
                          'View',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorValues.foreground,
                          ),
                        ),
                      )
                    else if (isApproved)
                      ElevatedButton(
                        onPressed: onViewProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorValues.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          'Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: onConsult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorValues.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(LucideIcons.calendarPlus, size: 13),
                        label: Text(
                          'Consult',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Image.asset(
        ImageAssets.seraGreeting,
        width: 44,
        fit: BoxFit.contain,
      ),
    );
  }
}

