import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/ring_ornament.dart';
import '../controllers/care_plan_controller.dart';

class CarePlanView extends GetView<CarePlanController> {
  const CarePlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        title: Text(
          'Care Plan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorValues.foreground,
          ),
        ),
        backgroundColor: ColorValues.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: ColorValues.border, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: ColorValues.primary),
          );
        }

        final plan = controller.activePlan.value;
        if (plan == null) {
          return Center(
            child: Text(
              'No active care plan found.',
              style: GoogleFonts.poppins(fontSize: 14, color: ColorValues.mutedForeground),
            ),
          );
        }

        final items = controller.filteredItems;

        return RefreshIndicator(
          onRefresh: controller.fetchCarePlans,
          color: ColorValues.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanSummaryCard(plan),
                const SizedBox(height: 20),
                _buildCategoryFilters(),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ColorValues.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorValues.border),
                    ),
                    child: Center(
                      child: Text(
                        'No items in this category.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ColorValues.mutedForeground,
                        ),
                      ),
                    ),
                  )
                else
                  ...items.map((item) => _buildItemCard(item)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlanSummaryCard(CarePlan plan) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorValues.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ColorValues.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const RingOrnament(),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'VERSION ${plan.version} · ACTIVE',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ColorValues.primaryForeground,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (plan.doctor != null)
                      Text(
                        plan.doctor!.name.split(',')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ColorValues.primaryForeground.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Doctor Prescription & Notes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorValues.primaryForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${plan.sourceText}"',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: ColorValues.primaryForeground.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {'key': 'all', 'label': 'All'},
      {'key': 'medication', 'label': 'Medications'},
      {'key': 'diet', 'label': 'Diet'},
      {'key': 'activity', 'label': 'Activity'},
      {'key': 'restriction', 'label': 'Restrictions'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = controller.selectedCategory.value == cat['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? ColorValues.primaryForeground : ColorValues.foreground,
                ),
              ),
              selected: isSelected,
              selectedColor: ColorValues.primary,
              backgroundColor: ColorValues.card,
              side: BorderSide(
                color: isSelected ? ColorValues.primary : ColorValues.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) => controller.selectCategory(cat['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCard(CarePlanItem item) {
    IconData icon;
    Color color;

    switch (item.kind) {
      case 'medication':
        icon = LucideIcons.pill;
        color = ColorValues.primary;
        break;
      case 'diet':
        icon = LucideIcons.salad;
        color = ColorValues.warning;
        break;
      case 'activity':
        icon = LucideIcons.footprints;
        color = ColorValues.success;
        break;
      case 'restriction':
        icon = LucideIcons.ban;
        color = ColorValues.destructive;
        break;
      default:
        icon = LucideIcons.calendarDays;
        color = ColorValues.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorValues.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: ColorValues.mutedForeground,
                    height: 1.4,
                  ),
                ),
                if (item.times.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: item.times.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorValues.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorValues.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
