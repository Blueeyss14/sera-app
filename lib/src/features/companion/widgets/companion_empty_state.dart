import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../res/colors.dart';
import '../../../shared/widgets/mascot_animations.dart';

class CompanionEmptyState extends StatelessWidget {
  final String firstName;
  final String mascotAsset;
  final bool isDisabled;
  final Function(String) onSelect;

  const CompanionEmptyState({
    super.key,
    required this.firstName,
    required this.mascotAsset,
    required this.isDisabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: ColorValues.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: MascotFloat(
              distance: 6.0,
              child: Image.asset(
                mascotAsset,
                width: 76,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hello, $firstName',
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
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: ColorValues.foreground,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCard(
                    width: itemWidth,
                    title: 'Medication schedule',
                    desc: 'What medications to take today',
                    question: 'What medications should I take now?',
                  ),
                  _buildCard(
                    width: itemWidth,
                    title: 'Dietary restrictions',
                    desc: 'Check allowed and restricted foods',
                    question: 'Can I eat salty food?',
                  ),
                  _buildCard(
                    width: itemWidth,
                    title: 'Explain instructions',
                    desc: 'Simple explanation from doctor',
                    question: 'Explain these doctor instructions',
                  ),
                  _buildCard(
                    width: itemWidth,
                    title: 'Medication dose',
                    desc: 'Doses and times for your medication',
                    question: 'What is my medication dose?',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required double width,
    required String title,
    required String desc,
    required String question,
  }) {
    return InkWell(
      onTap: isDisabled ? null : () => onSelect(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: 104,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorValues.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorValues.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: ColorValues.mutedForeground,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

