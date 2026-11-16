import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../controllers/companion_controller.dart';

class CompanionView extends GetView<CompanionController> {
  const CompanionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        backgroundColor: ColorValues.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: ColorValues.primaryLight,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(ImageAssets.seraGreeting, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sera Companion',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorValues.foreground,
                  ),
                ),
                Text(
                  'AI Recovery Assistant · Active Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: ColorValues.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: ColorValues.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: ColorValues.primary),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.messages.length + (controller.isSending.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length && controller.isSending.value) {
                    return _buildTypingIndicator();
                  }
                  final msg = controller.messages[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),
          _buildQuickPrompts(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isPatient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 48),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: ColorValues.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              msg.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ColorValues.primaryForeground,
                height: 1.4,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: ColorValues.primaryLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(ImageAssets.seraGreeting, fit: BoxFit.contain),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorValues.card,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: ColorValues.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: ColorValues.foreground,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (msg.source != null)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorValues.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.badgeCheck, size: 13, color: ColorValues.secondaryForeground),
                    const SizedBox(width: 4),
                    Text(
                      'Based on care plan v${msg.source!['version'] ?? 2}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorValues.secondaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (msg.isUrgent)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ColorValues.destructiveLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorValues.destructive.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.triangleAlert, color: ColorValues.destructive, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Immediate Assistance Needed',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ColorValues.destructive,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please contact emergency services (112) or go to the nearest emergency room.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 42),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ColorValues.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorValues.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: ColorValues.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sera is thinking...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ColorValues.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.quickPrompts.length,
        itemBuilder: (context, index) {
          final prompt = controller.quickPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                prompt,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorValues.foreground,
                ),
              ),
              backgroundColor: ColorValues.card,
              side: const BorderSide(color: ColorValues.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              onPressed: () => controller.sendMessage(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: ColorValues.card,
        border: Border(top: BorderSide(color: ColorValues.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorValues.border),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: GoogleFonts.poppins(fontSize: 14, color: ColorValues.foreground),
                  decoration: InputDecoration(
                    hintText: 'Ask Sera about medications or routine...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: ColorValues.mutedForeground,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => controller.sendMessage(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: ColorValues.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.send,
                  color: ColorValues.primaryForeground,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
