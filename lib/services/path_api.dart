import 'dart:convert';
import 'package:http/http.dart' as http;

class PathApi {
  // Switch between local dev and production
  static const String baseUrl =
      "http://10.219.193.1:5000"; // Android emulator → localhost
  // static const String baseUrl = "http://localhost:5000"; // iOS simulator / web
  // static const String baseUrl = "https://train-routing-api.onrender.com"; // Production

  /// Original endpoint — backward compatible, no time/day needed
  static Future<Map<String, dynamic>> getShortestPath(
    String source,
    String destination,
  ) async {
    return _post("/shortest-path", {
      "source": source,
      "destination": destination,
    });
  }

  /// Full-featured endpoint with date, time, coach class and budget
  static Future<Map<String, dynamic>> findRoute({
    required String source,
    required String destination,
    required String
    travelDay, // now accepts "YYYY-MM-DD" date OR "Mon"/"Tue" etc.
    required String startTime, // "HH:MM" 24-hour
    String preference = "any", // "ac", "sleeper", "any"
    String coachClass = "SL", // "GN","2S","SL","3E","CC","3A","2A","1A"
    int? budget, // max fare in Rs (optional)
  }) async {
    final body = <String, dynamic>{
      "source": source,
      "destination": destination,
      "start_time": startTime,
      "preference": preference,
      "coach_class": coachClass,
    };

    // If travelDay looks like a date (YYYY-MM-DD) send as travel_date,
    // otherwise send as travel_day (backward compat)
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(travelDay)) {
      body["travel_date"] = travelDay;
    } else {
      body["travel_day"] = travelDay;
    }

    if (budget != null && budget > 0) {
      body["budget"] = budget;
    }

    return _post("/find-route", body);
  }

  /// Fetch station list from server (with optional search query)
  static Future<List<String>> getStations({String query = ""}) async {
    final url = Uri.parse(
      query.isEmpty ? "$baseUrl/stations" : "$baseUrl/stations?q=$query",
    );
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["stations"]);
    }
    throw Exception("Failed to load stations");
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl$path");
    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Server error ${response.statusCode}");
    }
  }
}
