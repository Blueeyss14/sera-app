import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/ring_ornament.dart';

class DoctorProfileHeader extends StatelessWidget {
  final Doctor doctor;
  final bool isLoading;
  final VoidCallback onAction;
  final VoidCallback onBook;

  const DoctorProfileHeader({
    super.key,
    required this.doctor,
    required this.isLoading,
    required this.onAction,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = doctor.consultationStatus == 'pending';
    final isApproved = doctor.consultationStatus == 'approved';

    return Container(
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: ColorValues.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const RingOrnament(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: doctor.avatarUrl != null
                            ? Image.network(
                                doctor.avatarUrl!,
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
                        doctor.name,
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
                              doctor.specialty,
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
                        'Specialist at ${doctor.hospital}',
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
                          _buildContactChip(LucideIcons.building2, doctor.hospital),
                          _buildContactChip(LucideIcons.mail, doctor.email),
                          if (doctor.phone != null)
                            _buildContactChip(LucideIcons.phone, doctor.phone!),
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
            fontWeight: FontWeight.w500,
            color: ColorValues.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isPending, bool isApproved) {
    if (isLoading) {
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
        onPressed: onAction,
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
      onPressed: onBook,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: const Icon(LucideIcons.calendarPlus, size: 14),
      label: Text(
        'Book Consultation',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
