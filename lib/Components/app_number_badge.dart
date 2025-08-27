import 'package:flutter/material.dart';

import '../Core/Constants/app_colors.dart';

class AppNumberBadge extends StatelessWidget {
  const AppNumberBadge({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
