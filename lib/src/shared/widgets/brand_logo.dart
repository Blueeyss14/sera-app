import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../res/assets.dart';
import '../../../res/colors.dart';
import '../../../res/constant.dart';

enum BrandLogoSize { sm, md, lg }

class BrandLogo extends StatelessWidget {
  final BrandLogoSize size;
  final bool isInverted;
  final bool hasName;
  final String? caption;

  const BrandLogo({
    super.key,
    this.size = BrandLogoSize.md,
    this.isInverted = false,
    this.hasName = true,
    this.caption,
  });

  double get _iconSize {
    switch (size) {
      case BrandLogoSize.sm:
        return 32;
      case BrandLogoSize.md:
        return 36;
      case BrandLogoSize.lg:
        return 56;
    }
  }

  double get _fontSize {
    switch (size) {
      case BrandLogoSize.sm:
        return 17;
      case BrandLogoSize.md:
        return 20;
      case BrandLogoSize.lg:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = isInverted ? IconAssets.iconInverted : IconAssets.icon;
    final textColor = isInverted ? ColorValues.primaryForeground : ColorValues.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          width: _iconSize,
          height: _iconSize,
        ),
        if (hasName) ...[
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: GoogleFonts.poppins(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
