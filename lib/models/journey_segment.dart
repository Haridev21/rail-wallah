class JourneySegment {
  final String trainNo;
  final String fromStation;
  final String toStation;
  final List<String> stations;
  final double distance;

  JourneySegment({
    required this.trainNo,
    required this.fromStation,
    required this.toStation,
    required this.stations,
    required this.distance,
  });
}
