import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../controllers/doctors_controller.dart';
import 'doctor_profile_view.dart';

class DoctorsView extends GetView<DoctorsController> {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Doctors',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ColorValues.foreground,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find trusted specialists and request a consultation directly so your care plan can be monitored by experts.',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorValues.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ColorValues.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: ColorValues.foreground,
                      ),
                      onChanged: (val) => controller.onSearchChanged(val),
                      decoration: InputDecoration(
                        hintText: 'Search by doctor name, specialty, or hospital...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: ColorValues.mutedForeground,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          color: ColorValues.mutedForeground,
                          size: 18,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: ColorValues.primary),
                  );
                }

                if (controller.doctors.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorValues.muted.withValues(alpha: 0.5),
                            ),
                            child: const Icon(
                              LucideIcons.stethoscope,
                              size: 28,
                              color: ColorValues.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No doctors found',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ColorValues.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching with other keywords like doctor name, specialty, or hospital.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: ColorValues.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchDoctors(controller.searchController.text),
                  color: ColorValues.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: controller.doctors.length,
                    itemBuilder: (context, index) {
                      final doc = controller.doctors[index];
                      return _buildDoctorCard(context, doc);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doc) {
    final isPending = doc.consultationStatus == 'pending';
    final isApproved = doc.consultationStatus == 'approved';

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
          onTap: () => _openDoctorProfile(doc),
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
                      child: doc.avatarUrl != null
                          ? Image.network(
                              doc.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => _buildCardAvatarFallback(),
                            )
                          : _buildCardAvatarFallback(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
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
                                  doc.specialty,
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
                                  doc.hospital,
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
                if (doc.bio != null && doc.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    doc.bio!,
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
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () => _openDoctorProfile(doc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorValues.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'View Profile',
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

  Widget _buildCardAvatarFallback() {
    return Center(
      child: Image.asset(
        ImageAssets.seraGreeting,
        width: 44,
        fit: BoxFit.contain,
      ),
    );
  }

  void _openDoctorProfile(Doctor doc) {
    Get.to(() => DoctorProfileView(doctor: doc));
  }
}
