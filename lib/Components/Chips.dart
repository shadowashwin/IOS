import 'package:flutter/material.dart';

import '../Core/Constants/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip(this.label, {super.key, this.fontSize = 11});
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.chipText,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
