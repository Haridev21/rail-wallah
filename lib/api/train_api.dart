import 'dart:convert';
import 'package:http/http.dart' as http;

class TrainStation {
  final String stationName;
  final String timing;
  final String delay;
  final String? platform;
  final bool isCurrentStation;
  final String? message;

  TrainStation({
    required this.stationName,
    required this.timing,
    required this.delay,
    this.platform,
    this.isCurrentStation = false,
    this.message,
  });

  factory TrainStation.fromJson(Map<String, dynamic> json) {
    return TrainStation(
      stationName: json['station_name'] ?? '',
      timing: json['timing'] ?? '',
      delay: json['delay'] ?? '',
      platform: json['platform'],
      isCurrentStation: json['is_current_station'] == true,
      message: json['message'],
    );
  }
}

class TrainAPIResponse {
  final List<TrainStation> stations;
  final String? message;
  final String? trainName;
  final bool isError;

  TrainAPIResponse({
    required this.stations,
    this.message,
    this.trainName,
    this.isError = false,
  });
}

class TrainAPI {
  static Future<TrainAPIResponse> fetchTrainRoute(String trainNo) async {
    try {
      final url = Uri.parse('https://rappid.in/apis/train.php?train_no=$trainNo');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stationsData = data['data'];
        final String? message = data['message'];
        final String? trainName = data['train_name'];

        // Check if data is null or not a list (invalid train number)
        if (stationsData == null || stationsData is! List || stationsData.isEmpty) {
          return TrainAPIResponse(
            stations: [],
            message: message ?? 'Invalid train number. Please check and try again.',
            isError: true,
          );
        }

        return TrainAPIResponse(
          stations: stationsData.map((s) => TrainStation.fromJson(s as Map<String, dynamic>)).toList(),
          message: message,
          trainName: trainName,
        );
      } else {
        return TrainAPIResponse(
          stations: [],
          message: 'Server error. Please try again later.',
          isError: true,
        );
      }
    } catch (e) {
      return TrainAPIResponse(
        stations: [],
        message: 'Network error. Please check your connection and try again.',
        isError: true,
      );
    }
  }
}
