import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/mascot_animations.dart';
import '../../../shared/widgets/ring_ornament.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/today_controller.dart';

class TodayView extends GetView<TodayController> {
  const TodayView({super.key});

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

          final sched = controller.schedule.value;
          final plan = controller.activePlan.value;
          final streak = controller.adherence.value?.streak ?? 0;

          return RefreshIndicator(
            onRefresh: controller.fetchData,
            color: ColorValues.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (sched?.nextReminder != null) ...[
                    _buildNextReminderCard(sched!.nextReminder!),
                    const SizedBox(height: 24),
                  ],
                  _buildScheduleSection(sched),
                  const SizedBox(height: 24),
                  _buildAchievementsCard(streak),
                  const SizedBox(height: 20),
                  if (plan != null) _buildDietGuideCard(plan),
                  const SizedBox(height: 20),
                  if (plan != null) _buildFollowUpCard(plan),
                  const SizedBox(height: 20),
                  _buildReportPromptLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendarDays,
                    size: 14,
                    color: ColorValues.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.currentDateFormatted,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.mutedForeground,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${controller.greeting}, ${controller.honorific}\n${controller.patientFirstName}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const InteractiveMascot(size: 56),
      ],
    );
  }

  Widget _buildNextReminderCard(ReminderView reminder) {
    final isDone = reminder.isDone;
    final isOverdue = reminder.status == 'overdue';

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
            top: 16,
            right: 16,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: ClipOval(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MascotFloat(
                    child: Image.asset(
                      isOverdue ? ImageAssets.seraWorried : ImageAssets.seraGreeting,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOverdue ? 'Overdue' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ColorValues.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.clock,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reminder.time ?? 'Anytime today',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 96),
                  child: Text(
                    reminder.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(right: 96),
                  child: Text(
                    reminder.detail,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.toggleReminder(reminder),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorValues.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      isDone ? LucideIcons.check : LucideIcons.circleCheck,
                      size: 18,
                    ),
                    label: Text(
                      isDone ? 'Undo' : 'Mark as done',
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
    );
  }

  Widget _buildScheduleSection(TodayScheduleResponse? sched) {
    final done = sched?.doneCount ?? 0;
    final total = sched?.totalCount ?? 0;
    final reminders = sched?.reminders ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Schedule",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        if (total > 0) ...[
          Row(
            children: [
              Row(
                children: List.generate(total, (index) {
                  final isDone = index < done;
                  return Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? ColorValues.success : const Color(0xFFCBD5E1),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: '$done of $total schedules ',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ColorValues.foreground,
                  ),
                  children: [
                    TextSpan(
                      text: 'marked today',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (reminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorValues.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorValues.border),
            ),
            child: Text(
              'No scheduled reminders for today.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
              ),
            ),
          )
        else
          ...reminders.map((r) => _buildReminderItem(r)),
      ],
    );
  }

  Widget _buildReminderItem(ReminderView r) {
    final isDone = r.isDone;
    final isOverdue = r.status == 'overdue';
    final isAnytime = r.time == null || r.status == 'anytime';

    String overlineText;
    if (isDone) {
      overlineText = '${r.time ?? 'Today'} · Done';
    } else if (isOverdue) {
      overlineText = '${r.time ?? 'Today'} · Overdue';
    } else if (isAnytime) {
      overlineText = 'Today · Anytime';
    } else {
      overlineText = '${r.time} · Upcoming';
    }

    String detailText = r.detail;
    if (r.kind == 'activity' && detailText.contains(',')) {
      detailText = detailText.split(',').first.trim();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue && !isDone
              ? ColorValues.destructive.withValues(alpha: 0.4)
              : ColorValues.border,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? ColorValues.success.withValues(alpha: 0.12)
                  : isOverdue
                      ? ColorValues.destructive.withValues(alpha: 0.12)
                      : r.kind == 'activity'
                          ? ColorValues.secondary
                          : ColorValues.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              isDone
                  ? LucideIcons.check
                  : isOverdue
                      ? LucideIcons.circleAlert
                      : r.kind == 'medication'
                          ? LucideIcons.pill
                          : LucideIcons.footprints,
              color: isDone
                  ? ColorValues.success
                  : isOverdue
                      ? ColorValues.destructive
                      : r.kind == 'activity'
                          ? ColorValues.secondaryForeground
                          : ColorValues.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overlineText,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isOverdue && !isDone
                        ? ColorValues.destructive
                        : ColorValues.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isDone ? ColorValues.mutedForeground : ColorValues.foreground,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  detailText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => controller.toggleReminder(r),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ColorValues.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isDone ? 'Undo' : 'Done',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDone ? ColorValues.mutedForeground : ColorValues.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(int streak) {
    final unlockedCount = streak >= 3 ? 2 : streak >= 1 ? 1 : 1;
    final displayStreak = streak > 0 ? streak : 2;

    return Container(
      decoration: BoxDecoration(
        color: ColorValues.card,
        borderRadius: BorderRadius.circular(28),
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
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ColorValues.primary,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const RingOrnament(),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      const JumpingMascot(
                        imageAsset: ImageAssets.seraProud,
                        width: 72,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Achievements',
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$unlockedCount of 3 unlocked',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.flame,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$displayStreak days streak',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
              children: [
                _buildAchievementItem(
                  icon: LucideIcons.trophy,
                  isUnlocked: true,
                  title: 'First complete day',
                  description: 'All schedules in a single day completed.',
                ),
                const SizedBox(height: 16),
                _buildAchievementItem(
                  icon: LucideIcons.lock,
                  isUnlocked: false,
                  title: 'Three-day streak',
                  description: 'Three consecutive days with complete schedule.',
                ),
                const SizedBox(height: 16),
                _buildAchievementItem(
                  icon: LucideIcons.lock,
                  isUnlocked: false,
                  title: 'Consistent week',
                  description: 'Over 80% of schedule marked in the last 7 days.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required bool isUnlocked,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isUnlocked
                ? ColorValues.success.withValues(alpha: 0.15)
                : ColorValues.muted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isUnlocked ? ColorValues.success : ColorValues.mutedForeground,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: ColorValues.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.mutedForeground,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietGuideCard(CarePlan plan) {
    final dietItems = plan.items.where((i) => i.kind == 'diet').toList();
    if (dietItems.isEmpty) return const SizedBox.shrink();

    return Container(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorValues.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  LucideIcons.salad,
                  color: ColorValues.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Dietary Guidelines',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dietItems.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorValues.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Limit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.secondaryForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    i.category ?? 'Diet',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: ColorValues.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard(CarePlan plan) {
    final followUp = plan.items.firstWhereOrNull((i) => i.kind == 'followUp');
    if (followUp == null) return const SizedBox.shrink();

    DateTime? followUpDate;
    try {
      if (followUp.date != null) {
        followUpDate = DateTime.parse(followUp.date!);
      }
    } catch (_) {}

    final dateMonth = followUpDate != null
        ? DateFormat('MMM').format(followUpDate).toUpperCase()
        : 'NOV';
    final dateDay = followUpDate != null
        ? DateFormat('d').format(followUpDate)
        : '22';
    final fullDate = followUpDate != null
        ? DateFormat('EEEE, d MMMM yyyy').format(followUpDate)
        : 'Sunday, 22 November 2026';

    int daysLeft = 6;
    if (followUpDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(followUpDate.year, followUpDate.month, followUpDate.day);
      daysLeft = targetDate.difference(today).inDays;
    }

    final countdownText = daysLeft <= 0 ? 'Today' : daysLeft == 1 ? 'Tomorrow' : 'In $daysLeft days';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ColorValues.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorValues.primary,
                ),
                child: const Icon(
                  LucideIcons.calendarCheck,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Next Doctor Visit',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateMonth,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.primary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateDay,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.primary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countdownText,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.primary,
                      ),
                    ),
                    Text(
                      fullDate,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.foreground,
                      ),
                    ),
                    Text(
                      followUp.instruction ?? 'Routine blood pressure control',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (plan.doctor != null) ...[
            const SizedBox(height: 16),
            Divider(color: ColorValues.primary.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 12),
            Text(
              '${plan.doctor!.name} · ${plan.doctor!.hospital}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportPromptLink() {
    return InkWell(
      onTap: () {
        Get.find<MainController>().changeTab(2);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ColorValues.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorValues.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.messageSquareWarning,
              color: ColorValues.primary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have any complaints or issues?',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorValues.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Talk to Companion. Companion can also help you request a consultation.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.chevronRight,
              color: ColorValues.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
