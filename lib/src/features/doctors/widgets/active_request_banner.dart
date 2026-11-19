import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';

class ActiveRequestBanner extends StatelessWidget {
  final List<ConsultationRequestItem> requests;
  final Future<void> Function(String requestId) onCancel;

  const ActiveRequestBanner({
    super.key,
    required this.requests,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final pendingList = requests.where((r) => r.status == 'pending').toList();
    if (pendingList.isEmpty) return const SizedBox.shrink();

    final req = pendingList.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.clock, size: 14, color: Colors.amber),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Request',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final confirm = await Get.dialog<bool>(
                    AlertDialog(
                      title: Text(
                        'Cancel Request',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Are you sure you want to cancel this consultation request?',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          style: ElevatedButton.styleFrom(backgroundColor: ColorValues.destructive),
                          child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await onCancel(req.id);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.destructive,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            req.doctorName ?? 'Attending Doctor',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
            ),
          ),
          if (req.scheduledDate != null || req.scheduledTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 12, color: ColorValues.mutedForeground),
                const SizedBox(width: 5),
                Text(
                  '${req.scheduledDate ?? ''} ${req.scheduledTime != null ? 'at ${req.scheduledTime}' : ''}'.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ColorValues.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (req.notes != null && req.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Notes: ${req.notes}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: ColorValues.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

