import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/patient_models.dart';
import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../shared/widgets/mascot_animations.dart';
import '../controllers/companion_controller.dart';

class CompanionView extends GetView<CompanionController> {
  const CompanionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Companion',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorValues.foreground,
          ),
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

              if (controller.messages.isEmpty) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildEmptyState(),
                );
              }

              final showTyping = controller.isSending.value;
              final count = controller.messages.length + (showTyping ? 1 : 0);

              return ListView.builder(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: count,
                itemBuilder: (context, index) {
                  if (index == controller.messages.length && showTyping) {
                    return _buildTypingIndicator();
                  }
                  final msg = controller.messages[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),
          _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: ColorValues.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: MascotFloat(
              distance: 5.0,
              child: Image.asset(
                controller.mascotPoseAsset,
                width: 72,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hello, ${controller.firstName}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: ColorValues.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How can I help you today?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _buildSuggestionCard(
                title: 'Medication schedule',
                desc: 'What medications to take today',
                question: 'What medications should I take now?',
              ),
              _buildSuggestionCard(
                title: 'Dietary restrictions',
                desc: 'Check allowed and restricted foods',
                question: 'Can I eat salty food?',
              ),
              _buildSuggestionCard(
                title: 'Explain instructions',
                desc: 'Simple explanation from doctor',
                question: 'Explain these doctor instructions',
              ),
              _buildSuggestionCard(
                title: 'Medication dose',
                desc: 'Doses and times for your medication',
                question: 'What is my medication dose?',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required String desc,
    required String question,
  }) {
    return InkWell(
      onTap: () => controller.sendMessage(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorValues.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ColorValues.foreground,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanMarkdownStars(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isPatient) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 48),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: ColorValues.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              _cleanMarkdownStars(msg.content),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
        ),
      );
    }

    final bool isReported = controller.isMessageReported(msg);
    final bool hasEscalation = msg.isUrgent || msg.isOutOfScope;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: ColorValues.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.bottomCenter,
                child: ClipOval(
                  child: Image.asset(
                    ImageAssets.seraHappy,
                    width: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(color: ColorValues.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _cleanMarkdownStars(msg.content),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.foreground,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (msg.source != null)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.bookOpenCheck,
                      size: 12,
                      color: ColorValues.mutedForeground,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Based on care plan v${msg.source!['version'] ?? 2} · Dr. Haruka · 13 Oct',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (hasEscalation)
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: _buildEscalationCard(msg),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 4),
            child: InkWell(
              onTap: isReported ? null : () => controller.reportMessage(msg.id),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.flag,
                      size: 12,
                      color: isReported
                          ? ColorValues.primary
                          : ColorValues.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isReported ? 'Reported' : 'Report answer',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isReported
                            ? ColorValues.primary
                            : ColorValues.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationCard(ChatMessage msg) {
    final bool isUrgent = msg.isUrgent;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUrgent ? LucideIcons.phone : LucideIcons.stethoscope,
                size: 16,
                color: isUrgent
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFB45309),
              ),
              const SizedBox(width: 8),
              Text(
                isUrgent
                    ? 'Immediate Assistance Needed'
                    : 'Ask your doctor',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isUrgent
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isUrgent
                ? "Don't wait. Call emergency services or visit the nearest emergency room now."
                : 'This question should be answered directly by your doctor or healthcare professional.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ColorValues.foreground,
              height: 1.4,
            ),
          ),
          if (isUrgent) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.phoneCall, size: 15, color: Colors.white),
                label: Text(
                  'Call 119',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 44),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorValues.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Companion is typing...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        icon: LucideIcons.calendarPlus,
        label: 'Request schedule',
        message: 'I want to request a consultation schedule.',
      ),
      (
        icon: LucideIcons.messageSquareWarning,
        label: 'Report symptom',
        message: 'I want to share a health concern.',
      ),
      (
        icon: LucideIcons.pill,
        label: 'Medication schedule',
        message: 'What medications should I take now?',
      ),
      (
        icon: LucideIcons.salad,
        label: 'Dietary restrictions',
        message: 'Can I eat salty food?',
      ),
      (
        icon: LucideIcons.calendarCheck,
        label: 'Follow-up visit',
        message: 'When is my next doctor follow-up?',
      ),
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.sendMessage(action.message),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorValues.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action.icon,
                      size: 14,
                      color: ColorValues.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      action.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ColorValues.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColorValues.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorValues.border),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: controller.textController,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: ColorValues.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your question...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.mutedForeground,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                    border: InputBorder.none,
                    isDense: true,
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
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: ColorValues.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.send,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
