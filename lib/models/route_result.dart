


class RouteResult {
  final bool? found;
  final String? source;
  final String? destination;
  final String? travelDay;
  final String? travelDate;
  final String? startTime;
  final String? totalTime;
  final String? travelTime;
  final String? waitingTime;
  final int? totalMinutes;
  final int? travelMinutes;
  final int? waitingMinutes;
  final num? totalDistance;
  final num? distanceKm;
  final int? transfers;
  final List<dynamic>? segments;
  final List<PathStep>? path;

  

  final int? fare;
  final String? fareClass;
  final String? fareBreakdown;
  final List<dynamic>? farePerSegment;
  final Map<String, dynamic>? allClassFares;

  

  final bool? budgetExceeded;
  final int? budget;
  final int? budgetGap;
  final Map<String, dynamic>? budgetAlternative;

  RouteResult({
    this.found,
    this.source,
    this.destination,
    this.travelDay,
    this.travelDate,
    this.startTime,
    this.totalTime,
    this.travelTime,
    this.waitingTime,
    this.totalMinutes,
    this.travelMinutes,
    this.waitingMinutes,
    this.totalDistance,
    this.distanceKm,
    this.transfers,
    this.segments,
    this.path,
    this.fare,
    this.fareClass,
    this.fareBreakdown,
    this.farePerSegment,
    this.allClassFares,
    this.budgetExceeded,
    this.budget,
    this.budgetGap,
    this.budgetAlternative,
  });

  factory RouteResult.fromJson(Map<String, dynamic> j) {
    List<PathStep>? pathList;
    if (j['path'] is List) {
      pathList = (j['path'] as List)
          .map((e) => PathStep.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    

    final segs = j['segments'] as List?;
    final farePS = j['fare_per_segment'] as List?;
    if (segs != null && farePS != null) {
      for (final seg in segs) {
        if (seg is Map) {
          final match = farePS.firstWhere(
            (f) =>
                f is Map &&
                f['train_no']?.toString() == seg['train_no']?.toString(),
            orElse: () => null,
          );
          if (match != null) {
            seg['fare'] = match['fare'];
            seg['fare_class'] = match['class'];
          }
        }
      }
    }

    return RouteResult(
      found: j['found'] as bool?,
      source: j['source']?.toString(),
      destination: j['destination']?.toString(),
      travelDay: j['travel_day']?.toString(),
      travelDate: j['travel_date']?.toString(),
      startTime: j['start_time']?.toString(),
      totalTime: j['total_time']?.toString(),
      travelTime: j['travel_time']?.toString(),
      waitingTime: j['waiting_time']?.toString(),
      totalMinutes: (j['total_minutes'] as num?)?.toInt(),
      travelMinutes: (j['travel_minutes'] as num?)?.toInt(),
      waitingMinutes: (j['waiting_minutes'] as num?)?.toInt(),
      totalDistance: j['total_distance'] as num?,
      distanceKm: j['distance_km'] as num?,
      transfers: (j['transfers'] as num?)?.toInt(),
      segments: j['segments'] as List?,
      path: pathList,
      fare: (j['fare'] as num?)?.toInt(),
      fareClass: j['fare_class']?.toString(),
      fareBreakdown: j['fare_breakdown']?.toString(),
      farePerSegment: j['fare_per_segment'] as List?,
      allClassFares: j['all_class_fares'] != null
          ? Map<String, dynamic>.from(j['all_class_fares'] as Map)
          : null,
      budgetExceeded: j['budget_exceeded'] as bool?,
      budget: (j['budget'] as num?)?.toInt(),
      budgetGap: (j['budget_gap'] as num?)?.toInt(),
      budgetAlternative: j['budget_alternative'] != null
          ? Map<String, dynamic>.from(j['budget_alternative'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'found': found,
    'source': source,
    'destination': destination,
    'travel_day': travelDay,
    'travel_date': travelDate,
    'start_time': startTime,
    'total_time': totalTime,
    'travel_time': travelTime,
    'waiting_time': waitingTime,
    'total_minutes': totalMinutes,
    'travel_minutes': travelMinutes,
    'waiting_minutes': waitingMinutes,
    'total_distance': totalDistance,
    'distance_km': distanceKm,
    'transfers': transfers,
    'segments': segments,
    'path': path?.map((e) => e.toJson()).toList(),
    'fare': fare,
    'fare_class': fareClass,
    'fare_breakdown': fareBreakdown,
    'fare_per_segment': farePerSegment,
    'all_class_fares': allClassFares,
    'budget_exceeded': budgetExceeded,
    'budget': budget,
    'budget_gap': budgetGap,
    'budget_alternative': budgetAlternative,
  };
}

class PathStep {
  final String? station;
  final String? train;

  PathStep({this.station, this.train});

  factory PathStep.fromJson(Map<String, dynamic> j) => PathStep(
    station: j['station']?.toString(),
    train: j['train']?.toString(),
  );

  Map<String, dynamic> toJson() => {'station': station, 'train': train};
}
