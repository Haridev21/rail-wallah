import 'package:flutter/material.dart';

class TrainChangeWidget extends StatelessWidget {
  const TrainChangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.sync_alt, color: Colors.orange),
        SizedBox(width: 6),
        Text(
          "Change Train",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
