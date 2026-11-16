import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/patient_models.dart';
import '../../../res/colors.dart';
import '../../features/main/controllers/main_controller.dart';
import 'ring_ornament.dart';

void showCarePlanItemDialog(
  BuildContext context, {
  required CarePlanItem item,
  required CarePlan plan,
  String? categoryLabel,
}) {
  final label = categoryLabel ?? resolveCategoryLabel(item);
  final detailRows = getCarePlanItemDetailRows(item);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorValues.primary,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    const RingOrnament(),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 60, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorValues.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getCarePlanItemTitle(item),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getCarePlanItemSummary(item),
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...detailRows.map((row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row['label']!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.7,
                                color: ColorValues.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row['value']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorValues.foreground,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorValues.muted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOCTOR ORIGINAL NOTES',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: ColorValues.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.sourceText,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: ColorValues.foreground,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Get.find<MainController>().changeTab(2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorValues.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          LucideIcons.messageCircleHeart,
                          size: 18,
                        ),
                        label: Text(
                          'Ask Companion about this',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String resolveCategoryLabel(CarePlanItem item) {
  switch (item.kind) {
    case 'medication':
      return 'Medication';
    case 'diet':
      return 'Diet';
    case 'activity':
      return 'Activity';
    case 'restriction':
      return 'Restriction';
    case 'followUp':
    default:
      return 'Doctor Follow-up';
  }
}

String getCarePlanItemTitle(CarePlanItem item) {
  switch (item.kind) {
    case 'medication':
      return '${item.drug ?? ''} ${item.dose ?? ''}'.trim();
    case 'diet':
      final ruleLabel = item.rule == 'avoid'
          ? 'Avoid'
          : item.rule == 'limit'
              ? 'Limit'
              : 'Recommended';
      return '$ruleLabel ${item.category?.toLowerCase() ?? 'diet'}';
    case 'activity':
      return item.activity ?? 'Activity';
    case 'restriction':
      return 'Limit ${item.subject?.toLowerCase() ?? ''}';
    case 'followUp':
    default:
      return 'Doctor follow-up';
  }
}

String getCarePlanItemSummary(CarePlanItem item) {
  switch (item.kind) {
    case 'medication':
      if (item.times.isNotEmpty) {
        final freq = item.times.length == 1
            ? 'Once daily'
            : '${item.times.length}x daily';
        return '$freq, at ${item.times.join(' and ')}';
      }
      return item.instruction ?? '';
    case 'diet':
      return item.instruction ?? '';
    case 'activity':
      final duration = item.durationMinutes != null
          ? '${item.durationMinutes} mins'
          : '30 mins';
      final freq = item.frequencyPerWeek != null
          ? ', ${item.frequencyPerWeek}x weekly'
          : '';
      return '$duration$freq';
    case 'restriction':
      return item.instruction ?? '';
    case 'followUp':
    default:
      if (item.date != null) {
        try {
          final parsed = DateTime.parse(item.date!);
          return DateFormat('EEEE, d MMMM yyyy').format(parsed);
        } catch (_) {
          return item.date!;
        }
      }
      return item.instruction ?? '';
  }
}

List<Map<String, String>> getCarePlanItemDetailRows(CarePlanItem item) {
  switch (item.kind) {
    case 'medication':
      return [
        {'label': 'DOSE', 'value': item.dose ?? '-'},
        {
          'label': 'FREQUENCY',
          'value': item.times.length == 1
              ? 'Once daily'
              : '${item.times.length}x daily',
        },
        {'label': 'SCHEDULED TIME', 'value': item.times.join(', ')},
        {'label': 'DURATION', 'value': '${item.durationDays ?? 90} days'},
        {'label': 'INSTRUCTION', 'value': item.instruction ?? '-'},
      ];
    case 'diet':
      return [
        {
          'label': 'RULE',
          'value': item.rule == 'avoid'
              ? 'Avoid'
              : item.rule == 'limit'
                  ? 'Limit'
                  : 'Recommended',
        },
        {'label': 'CATEGORY', 'value': item.category ?? '-'},
        {'label': 'NOTE', 'value': item.instruction ?? '-'},
      ];
    case 'activity':
      return [
        {'label': 'DURATION', 'value': '${item.durationMinutes ?? 30} minutes'},
        {'label': 'FREQUENCY', 'value': '${item.frequencyPerWeek ?? 5}x weekly'},
        {'label': 'NOTE', 'value': item.instruction ?? '-'},
      ];
    case 'restriction':
      return [
        {'label': 'RESTRICTED ITEM', 'value': item.subject ?? '-'},
        {
          'label': 'DURATION',
          'value': item.durationDays == null
              ? 'During treatment period'
              : '${item.durationDays} days',
        },
        {'label': 'NOTE', 'value': item.instruction ?? '-'},
      ];
    case 'followUp':
    default:
      String dateStr = item.date ?? '-';
      if (item.date != null) {
        try {
          final parsed = DateTime.parse(item.date!);
          dateStr = DateFormat('EEEE, d MMMM yyyy').format(parsed);
        } catch (_) {}
      }
      return [
        {'label': 'DATE', 'value': dateStr},
        {'label': 'NOTE', 'value': item.instruction ?? '-'},
      ];
  }
}
