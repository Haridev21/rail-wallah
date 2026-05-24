import 'package:flutter/material.dart';
import 'panorama_scene.dart';

// A starting location inside the station (e.g. Platform 1, Entrance)
class StartingPoint {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final List<PanoramaScene> scenes; // scenes for THIS starting point
  // Maps icon id → which scene index that destination is found in
  final Map<String, int> destinationSceneMap;

  const StartingPoint({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.scenes,
    required this.destinationSceneMap,
  });
}

// A navigable destination the user can search for
class Destination {
  final String id; // matches PanoramaIcon.id
  final String label;
  final IconData icon;
  final Color color;

  const Destination({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// Top-level station entry
class Station {
  final String name;
  final String subtitle;
  final String code;
  final Color accentColor;
  final List<StartingPoint> startingPoints;
  final List<Destination> destinations; // all possible destinations

  const Station({
    required this.name,
    required this.subtitle,
    required this.code,
    required this.accentColor,
    required this.startingPoints,
    required this.destinations,
  });
}
