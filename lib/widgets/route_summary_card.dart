import 'package:flutter/material.dart';

class RouteSummaryCard extends StatelessWidget {
  final String source;
  final String destination;
  final double distance;
  final int stops;
  final int trainChanges;

  const RouteSummaryCard({
    super.key,
    required this.source,
    required this.destination,
    required this.distance,
    required this.stops,
    required this.trainChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$source → $destination",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Distance: ${distance.toInt()} km"),
            Text("Stops: $stops"),
            Text("Train Changes: $trainChanges"),
          ],
        ),
      ),
    );
  }
}
