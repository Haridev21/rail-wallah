// lib/services/train_service.dart
//
// Calls the Rappid free API — no API key required.
// URL: https://rappid.in/apis/train.php?train_no=12354

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/train_info.dart';
import '../models/coach_config.dart';
import 'coach_template_service.dart';

class TrainServiceException implements Exception {
  final String message;
  const TrainServiceException(this.message);
  @override
  String toString() => message;
}

class TrainService {
  static const String _baseUrl = 'https://rappid.in/apis/train.php';

  static Future<TrainInfo> fetchTrain(String trainNo) async {
    final trainNum = trainNo.trim();

    if (trainNum.isEmpty) {
      throw const TrainServiceException('Please enter a train number.');
    }
    if (trainNum.length < 4 || trainNum.length > 5) {
      throw const TrainServiceException('Train number must be 4–5 digits.');
    }

    final uri = Uri.parse('$_baseUrl?train_no=$trainNum');

    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const TrainServiceException(
        'Network error. Please check your connection.',
      );
    }

    if (response.statusCode != 200) {
      throw TrainServiceException(
        'Server error (${response.statusCode}). Try again.',
      );
    }

    late Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const TrainServiceException('Unexpected response from server.');
    }

    // Rappid returns { "success": false } for invalid train numbers
    final success = json['success'];
    if (success == false || success == 'false') {
      throw const TrainServiceException(
        'Train not found. Please check the number.',
      );
    }

    final rawName = json['train_name']?.toString() ?? '';
    final List<CoachConfig> coaches = CoachTemplateService.resolve(
      trainNum,
      rawName,
    );

    return TrainInfo.fromJson(trainNum, json, coaches);
  }
}
