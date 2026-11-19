import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';

class ScheduleTimeSlots extends StatelessWidget {
  final List<DoctorSlot> slots;
  final String? selectedTime;
  final bool isLoading;
  final ValueChanged<String?> onSlotToggled;

  const ScheduleTimeSlots({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.isLoading,
    required this.onSlotToggled,
  });

  @override
  Widget build(BuildContext context) {
    final availableCount = slots.where((s) => s.isAvailable).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Time Slots',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: ColorValues.foreground,
              ),
            ),
            if (!isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorValues.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$availableCount available',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.primary),
              ),
            ),
          )
        else if (slots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: ColorValues.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorValues.border),
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.calendarX2, size: 28, color: ColorValues.mutedForeground),
                const SizedBox(height: 8),
                Text(
                  'No consultation slots on this date',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please pick another date from the calendar above.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: ColorValues.mutedForeground,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) => _buildSlotChip(slot)).toList(),
          ),
      ],
    );
  }

  Widget _buildSlotChip(DoctorSlot slot) {
    final isSelected = selectedTime == slot.time;
    final isAvailable = slot.isAvailable;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isAvailable
          ? () {
              onSlotToggled(isSelected ? null : slot.time);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: !isAvailable
              ? ColorValues.muted.withValues(alpha: 0.45)
              : isSelected
                  ? ColorValues.primary
                  : ColorValues.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !isAvailable
                ? ColorValues.border.withValues(alpha: 0.5)
                : isSelected
                    ? ColorValues.primary
                    : ColorValues.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorValues.primary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? LucideIcons.circleCheck
                  : isAvailable
                      ? LucideIcons.clock
                      : LucideIcons.slash,
              size: 13,
              color: !isAvailable
                  ? ColorValues.mutedForeground.withValues(alpha: 0.6)
                  : isSelected
                      ? Colors.white
                      : ColorValues.mutedForeground,
            ),
            const SizedBox(width: 6),
            Text(
              slot.time,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: !isAvailable
                    ? ColorValues.mutedForeground.withValues(alpha: 0.5)
                    : isSelected
                        ? Colors.white
                        : ColorValues.foreground,
                decoration: !isAvailable ? TextDecoration.lineThrough : null,
              ),
            ),
            if (!isAvailable) ...[
              const SizedBox(width: 4),
              Text(
                'Full',
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: ColorValues.mutedForeground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

