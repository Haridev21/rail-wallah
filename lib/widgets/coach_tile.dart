// lib/widgets/coach_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coach_config.dart';
import '../constants/colors.dart';

class CoachTile extends StatelessWidget {
  final CoachConfig coach;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final int availableCount;
  final VoidCallback? onTap;

  const CoachTile({
    super.key,
    required this.coach,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.availableCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = coach.accentColor;
    final isSmall =
        coach.type == CoachType.engine || coach.type == CoachType.guard;

    return GestureDetector(
      onTap: coach.isBookable ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFirst)
            Container(
              width: 8,
              height: 6,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: isSelected ? color : kAisle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: isSmall ? 46 : 52,
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.22) : kCoachBg,
              borderRadius: BorderRadius.horizontal(
                left: isFirst ? const Radius.circular(12) : Radius.zero,
                right: isLast ? const Radius.circular(12) : Radius.zero,
              ),
              border: Border.all(
                color: isSelected ? color : kCoachBorder,
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  coach.label,
                  style: GoogleFonts.sora(
                    color: isSelected ? color : kTextSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(coach.icon, color: isSelected ? color : kAisle, size: 15),
                if (coach.isBookable && availableCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$availableCount',
                    style: GoogleFonts.inter(
                      color: isSelected ? color : kRowNum,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
