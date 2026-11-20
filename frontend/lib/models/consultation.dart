class ConsultationSession {
  final String id;
  final String userId;
  final String astrologerId;
  final String type;
  final String status;
  final double ratePerMinute;
  final int durationSeconds;
  final double totalDeducted;
  final String? startedAt;
  final String? endedAt;

  ConsultationSession({
    required this.id,
    required this.userId,
    required this.astrologerId,
    required this.type,
    required this.status,
    required this.ratePerMinute,
    required this.durationSeconds,
    required this.totalDeducted,
    this.startedAt,
    this.endedAt,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    return ConsultationSession(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      astrologerId: json['astrologer_id'] ?? '',
      type: json['type'] ?? 'chat',
      status: json['status'] ?? 'active',
      ratePerMinute: (json['rate_per_minute'] as num?)?.toDouble() ?? 20.0,
      durationSeconds: json['duration_seconds'] ?? 0,
      totalDeducted: (json['total_deducted'] as num?)?.toDouble() ?? 0.0,
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
    );
  }
}
