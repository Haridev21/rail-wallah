import 'package:flutter/material.dart';

class PanoramaIcon {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  // Longitude: -180 to 180 (horizontal position on sphere)
  // Latitude:  -90  to 90  (vertical position on sphere)
  // ⚠️ UPDATE these values using the debug double-tap tool in each scene
  final double longitude;
  final double latitude;

  const PanoramaIcon({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.longitude,
    required this.latitude,
  });
}
