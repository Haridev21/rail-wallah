// lib/models/coach_config.dart

import 'package:flutter/material.dart';

enum CoachType { engine, ac1, ac2, ac3, sleeper, pantry, guard, general }

class CoachConfig {
  final String label;
  final CoachType type;
  final int rows;
  final bool hasLastRow5;

  const CoachConfig({
    required this.label,
    required this.type,
    required this.rows,
    this.hasLastRow5 = false,
  });

  int get totalSeats => rows * 4 + (hasLastRow5 ? 5 : 0);

  bool get isBookable =>
      type != CoachType.engine &&
      type != CoachType.pantry &&
      type != CoachType.guard;

  String get typeName {
    switch (type) {
      case CoachType.engine:
        return 'Engine';
      case CoachType.ac1:
        return 'AC 1st Class';
      case CoachType.ac2:
        return 'AC 2-Tier';
      case CoachType.ac3:
        return 'AC 3-Tier';
      case CoachType.sleeper:
        return 'Sleeper';
      case CoachType.pantry:
        return 'Pantry Car';
      case CoachType.guard:
        return 'Guard Van';
      case CoachType.general:
        return 'General';
    }
  }

  Color get accentColor {
    switch (type) {
      case CoachType.engine:
        return const Color(0xFFEF4444);
      case CoachType.ac1:
        return const Color(0xFFD97706);
      case CoachType.ac2:
        return const Color(0xFF7C3AED);
      case CoachType.ac3:
        return const Color(0xFF2563EB);
      case CoachType.sleeper:
        return const Color(0xFF059669);
      case CoachType.pantry:
        return const Color(0xFFEA580C);
      case CoachType.guard:
        return const Color(0xFF475569);
      case CoachType.general:
        return const Color(0xFF64748B);
    }
  }

  IconData get icon {
    switch (type) {
      case CoachType.engine:
        return Icons.train_rounded;
      case CoachType.ac1:
        return Icons.star_rounded;
      case CoachType.ac2:
        return Icons.ac_unit_rounded;
      case CoachType.ac3:
        return Icons.event_seat_rounded;
      case CoachType.sleeper:
        return Icons.airline_seat_flat_rounded;
      case CoachType.pantry:
        return Icons.kitchen_rounded;
      case CoachType.guard:
        return Icons.security_rounded;
      case CoachType.general:
        return Icons.people_rounded;
    }
  }
}
