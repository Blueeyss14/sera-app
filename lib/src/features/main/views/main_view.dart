import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../res/colors.dart';
import '../../care_plan/views/care_plan_view.dart';
import '../../companion/views/companion_view.dart';
import '../../doctors/views/doctors_view.dart';
import '../../profile/views/profile_view.dart';
import '../../today/views/today_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TodayView(),
      const CarePlanView(),
      const CompanionView(),
      const DoctorsView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: ColorValues.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: ColorValues.card,
            border: Border(
              top: BorderSide(color: ColorValues.border, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  _buildNavItem(0, LucideIcons.house, 'Today'),
                  _buildNavItem(1, LucideIcons.clipboardList, 'Care Plan'),
                  _buildNavItem(2, LucideIcons.messageCircleHeart, 'Companion'),
                  _buildNavItem(3, LucideIcons.search, 'Doctors'),
                  _buildNavItem(4, LucideIcons.userRound, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = controller.currentIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorValues.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? ColorValues.primary : ColorValues.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? ColorValues.primary : ColorValues.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
