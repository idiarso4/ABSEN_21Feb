class Leave {
  final int id;
  final int userId;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final DateTime createdAt;

  Leave({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      userId: json['user_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reason: json['reason'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 