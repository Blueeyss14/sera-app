import 'package:flutter/material.dart';

class RingOrnament extends StatelessWidget {
  const RingOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    const ringSizes = [512.0, 384.0, 288.0, 192.0];
    const maxSize = 512.0;

    return Positioned(
      right: -24.0 - (maxSize / 2),
      bottom: -40.0 - (maxSize / 2),
      child: IgnorePointer(
        child: SizedBox(
          width: maxSize,
          height: maxSize,
          child: Stack(
            alignment: Alignment.center,
            children: ringSizes.map((size) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
