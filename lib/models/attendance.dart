class Attendance {
  final int id;
  final int userId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'check_in': checkIn,
      'check_out': checkOut,
      'status': status,
    };
  }
} 