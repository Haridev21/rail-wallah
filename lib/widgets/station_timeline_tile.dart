import 'package:flutter/material.dart';

class StationTimelineTile extends StatelessWidget {
  final String station;
  final String? train;

  const StationTimelineTile({super.key, required this.station, this.train});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.train),
      title: Text(station),
      subtitle: train != null ? Text("Train: $train") : const Text("Start"),
    );
  }
}
