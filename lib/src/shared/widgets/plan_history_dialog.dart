import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/patient_models.dart';
import '../../../res/colors.dart';
import 'care_plan_item_dialog.dart';
import 'ring_ornament.dart';

void showPlanHistoryDialog(BuildContext context, {required CarePlan plan}) {
  String confirmedDateStr = 'Pending confirmation';
  if (plan.confirmedAt != null) {
    try {
      final parsed = DateTime.parse(plan.confirmedAt!);
      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      confirmedDateStr =
          'Confirmed ${parsed.day} ${monthNames[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      confirmedDateStr = 'Confirmed ${plan.confirmedAt}';
    }
  }

  final bool isActive = plan.status == 'active';
  const kindOrder = [
    'medication',
    'diet',
    'activity',
    'restriction',
    'followUp',
  ];

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
                decoration: const BoxDecoration(color: ColorValues.primary),
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
                              isActive ? 'Active' : 'Superseded',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorValues.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Care Plan Version ${plan.version}',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${plan.doctor?.name != null ? "${plan.doctor!.name} · " : ""}$confirmedDateStr',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
                    Text(
                      'DOCTOR NOTES',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorValues.muted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorValues.border),
                      ),
                      child: Text(
                        plan.sourceText,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          color: ColorValues.foreground,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...kindOrder.map((kind) {
                      final items = plan.items
                          .where((i) => i.kind == kind)
                          .toList();
                      if (items.isEmpty) return const SizedBox.shrink();

                      String categoryHeader = 'MEDICATION';
                      if (kind == 'diet') {
                        categoryHeader = 'DIET & NUTRITION';
                      } else if (kind == 'activity') {
                        categoryHeader = 'PHYSICAL ACTIVITY';
                      } else if (kind == 'restriction') {
                        categoryHeader = 'RESTRICTIONS';
                      } else if (kind == 'followUp') {
                        categoryHeader = 'FOLLOW-UP CONSULTATION';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryHeader,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: ColorValues.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorValues.card,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: ColorValues.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: items.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isLast = index == items.length - 1;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getCarePlanItemTitle(item),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ColorValues.foreground,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  getCarePlanItemSummary(item),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorValues
                                                        .mutedForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: ColorValues.border,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      );
                    }),
                    if (!isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(
                          'This version has been superseded by a newer version. Your daily schedule follows the active plan.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: ColorValues.mutedForeground,
                            fontStyle: FontStyle.italic,
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
