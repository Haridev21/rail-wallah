import '../models/journey_segment.dart';

List<JourneySegment> buildJourneySegments(
  List<dynamic> path,
  double totalDistance,
) {
  List<JourneySegment> segments = [];

  String? currentTrain;
  List<String> currentStations = [];
  double segmentDistance = 0.0;

  for (int i = 1; i < path.length; i++) {
    final prev = path[i - 1];
    final curr = path[i];

    final train = curr['train'];
    final station = curr['station'];

    if (currentTrain == null) {
      currentTrain = train;
      currentStations.add(prev['station']);
    }

    if (train != currentTrain) {
      segments.add(
        JourneySegment(
          trainNo: currentTrain!,
          fromStation: currentStations.first,
          toStation: currentStations.last,
          stations: List.from(currentStations),
          distance: segmentDistance,
        ),
      );

      currentTrain = train;
      currentStations = [prev['station']];
      segmentDistance = 0.0;
    }

    currentStations.add(station);
    segmentDistance += 1; // logical hop (distance already totalled elsewhere)
  }

  if (currentTrain != null && currentStations.length > 1) {
    segments.add(
      JourneySegment(
        trainNo: currentTrain,
        fromStation: currentStations.first,
        toStation: currentStations.last,
        stations: currentStations,
        distance: segmentDistance,
      ),
    );
  }

  return segments;
}
