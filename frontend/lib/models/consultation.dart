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

  factory ConsultationSession.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ConsultationSession(
        id: '',
        userId: '',
        astrologerId: '',
        type: 'chat',
        status: 'completed',
        ratePerMinute: 25.0,
        durationSeconds: 0,
        totalDeducted: 0.0,
      );
    }
    return ConsultationSession(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      astrologerId: json['astrologer_id']?.toString() ?? json['astrologerId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'chat',
      status: json['status']?.toString() ?? 'active',
      ratePerMinute: (json['rate_per_minute'] ?? json['ratePerMinute'] as num?)?.toDouble() ?? 20.0,
      durationSeconds: json['duration_seconds'] ?? json['durationSeconds'] ?? 0,
      totalDeducted: (json['total_deducted'] ?? json['totalDeducted'] as num?)?.toDouble() ?? 0.0,
      startedAt: json['started_at']?.toString() ?? json['startedAt']?.toString(),
      endedAt: json['ended_at']?.toString() ?? json['endedAt']?.toString(),
    );
  }
}
