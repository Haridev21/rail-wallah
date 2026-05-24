class RailUpdate {
  final String source;
  final String message;
  final String time;

  RailUpdate({required this.source, required this.message, required this.time});

  factory RailUpdate.fromJson(Map<String, dynamic> json) {
    return RailUpdate(
      source: json['source'],
      message: json['message'],
      time: json['time'],
    );
  }
}
