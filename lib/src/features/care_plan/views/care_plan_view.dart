import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/mascot_animations.dart';
import '../../../shared/widgets/ring_ornament.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/care_plan_controller.dart';

class CarePlanView extends GetView<CarePlanController> {
  const CarePlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: ColorValues.primary),
            );
          }

          final plan = controller.activePlan.value;
          if (plan == null) {
            return RefreshIndicator(
              onRefresh: controller.fetchCarePlans,
              color: ColorValues.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  const EmptyState(
                    title: 'No active care plan yet',
                    description:
                        'Care plans will appear here once confirmed by your doctor.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchCarePlans,
            color: ColorValues.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPlanSummaryCard(plan),
                  const SizedBox(height: 24),
                  ..._buildCategorySections(context, plan),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Care Plan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Active instructions from your doctor, grouped by category.',
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: ColorValues.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSummaryCard(CarePlan plan) {
    String effectiveDate = '-';
    if (plan.confirmedAt != null) {
      try {
        final parsed = DateTime.parse(plan.confirmedAt!).toLocal();
        effectiveDate = DateFormat('d MMM yyyy, HH:mm').format(parsed);
      } catch (_) {
        effectiveDate = plan.confirmedAt!;
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorValues.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ColorValues.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const RingOrnament(),
          Positioned(
            right: 14,
            bottom: 0,
            child: PeekingMascot(
              child: MascotSway(
                child: Image.asset(
                  ImageAssets.seraClipboard,
                  width: 88,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFactItem(
                  label: 'DOCTOR',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.doctor?.name ?? 'Dr. Haruka Tanaka, MD',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (plan.doctor?.hospital != null)
                        Text(
                          plan.doctor!.hospital,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildFactItem(
                  label: 'VERSION',
                  child: Row(
                    children: [
                      Text(
                        'Version ${plan.version}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorValues.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildFactItem(
                  label: 'EFFECTIVE SINCE',
                  child: Text(
                    effectiveDate,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 3),
        child,
      ],
    );
  }

  List<Widget> _buildCategorySections(BuildContext context, CarePlan plan) {
    const kindOrder = ['medication', 'diet', 'activity', 'restriction', 'followUp'];
    final widgets = <Widget>[];

    for (final kind in kindOrder) {
      final items = controller.getItemsByKind(kind);
      if (items.isEmpty) continue;

      widgets.add(_buildCategoryCard(context, kind, items, plan));
    }

    return widgets;
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String kind,
    List<CarePlanItem> items,
    CarePlan plan,
  ) {
    IconData icon;
    String label;

    switch (kind) {
      case 'medication':
        icon = LucideIcons.pill;
        label = 'Medication';
        break;
      case 'diet':
        icon = LucideIcons.salad;
        label = 'Diet';
        break;
      case 'activity':
        icon = LucideIcons.footprints;
        label = 'Activity';
        break;
      case 'restriction':
        icon = LucideIcons.shieldAlert;
        label = 'Restrictions';
        break;
      case 'followUp':
      default:
        icon = LucideIcons.calendarCheck;
        label = 'Follow-up';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: ColorValues.muted.withValues(alpha: 0.35),
              border: const Border(
                bottom: BorderSide(color: ColorValues.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorValues.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: ColorValues.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorValues.border.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    '${items.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: () => _showItemDialog(context, item, plan, label),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getItemTitle(item),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: ColorValues.foreground,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _getItemSummary(item),
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  color: ColorValues.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 20,
                          color: ColorValues.mutedForeground,
                        ),
                      ],
                    ),
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
          }),
        ],
      ),
    );
  }

  String _getItemTitle(CarePlanItem item) {
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

  String _getItemSummary(CarePlanItem item) {
    switch (item.kind) {
      case 'medication':
        if (item.times.isNotEmpty) {
          final freq = item.times.length == 1 ? 'Once daily' : '${item.times.length}x daily';
          return '$freq, at ${item.times.join(' and ')}';
        }
        return item.instruction ?? '';
      case 'diet':
        return item.instruction ?? '';
      case 'activity':
        final duration = item.durationMinutes != null ? '${item.durationMinutes} mins' : '30 mins';
        final freq = item.frequencyPerWeek != null ? ', ${item.frequencyPerWeek}x weekly' : '';
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

  void _showItemDialog(
    BuildContext context,
    CarePlanItem item,
    CarePlan plan,
    String categoryLabel,
  ) {
    final detailRows = _getItemDetailRows(item);

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
                  decoration: const BoxDecoration(
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                categoryLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorValues.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getItemTitle(item),
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getItemSummary(item),
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
                          icon: const Icon(LucideIcons.messageCircleHeart, size: 18),
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

  List<Map<String, String>> _getItemDetailRows(CarePlanItem item) {
    switch (item.kind) {
      case 'medication':
        return [
          {'label': 'DOSE', 'value': item.dose ?? '-'},
          {
            'label': 'FREQUENCY',
            'value': item.times.length == 1 ? 'Once daily' : '${item.times.length}x daily',
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
}
