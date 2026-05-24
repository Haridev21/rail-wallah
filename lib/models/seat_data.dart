// lib/models/seat_data.dart

enum SeatStatus { available, booked, ladies, premium }

class SeatData {
  final String id;
  SeatStatus status;
  SeatData({required this.id, required this.status});
}
