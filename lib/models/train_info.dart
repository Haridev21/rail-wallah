// lib/models/train_info.dart

import 'coach_config.dart';

class TrainInfo {
  final String trainNo;
  final String trainName;
  final String fromStnName;
  final String toStnName;
  final String departure;
  final String arrival;
  final List<CoachConfig> coaches;

  const TrainInfo({
    required this.trainNo,
    required this.trainName,
    required this.fromStnName,
    required this.toStnName,
    required this.departure,
    required this.arrival,
    required this.coaches,
  });

  /// Parses the real Rappid API response:
  /// {
  ///   "success": true,
  ///   "train_name": "12354 Lku Hwh Sf Exp Running Status",
  ///   "data": [
  ///     { "station_name": "Lal Kuan", "timing": "18:5018:50", "halt": "Source" },
  ///     ...
  ///     { "station_name": "Howrah Jn", "timing": "Destination", "halt": "Destination" }
  ///   ]
  /// }
  factory TrainInfo.fromJson(
    String trainNo,
    Map<String, dynamic> json,
    List<CoachConfig> coaches,
  ) {
    // Strip " Running Status" and leading train number from name
    final rawName = json['train_name']?.toString() ?? 'Unknown Train';
    final cleaned = rawName
        .replaceAll(RegExp(r'\s*Running Status\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\d+\s*'), '')
        .trim();
    final trainName = cleaned.isNotEmpty ? cleaned : rawName;

    final data = (json['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final source = data.isNotEmpty ? data.first : <String, dynamic>{};
    final dest = data.isNotEmpty ? data.last : <String, dynamic>{};

    // timing looks like "18:5018:50" — take first 5 chars
    String parseTime(String raw) {
      if (raw.length >= 5 && raw.contains(':')) return raw.substring(0, 5);
      return '--:--';
    }

    return TrainInfo(
      trainNo: trainNo,
      trainName: trainName,
      fromStnName: source['station_name']?.toString() ?? '',
      toStnName: dest['station_name']?.toString() ?? '',
      departure: parseTime(source['timing']?.toString() ?? ''),
      arrival: parseTime(dest['timing']?.toString() ?? ''),
      coaches: coaches,
    );
  }
}
