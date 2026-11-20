class Astrologer {
  final String id;
  final String displayName;
  final List<String> specialties;
  final List<String> languages;
  final int experienceYears;
  final double ratePerMinute;
  final double rating;
  final int totalReviews;
  final bool isOnline;
  final bool isBusy;
  final String bio;
  final String avatarUrl;

  Astrologer({
    required this.id,
    required this.displayName,
    required this.specialties,
    required this.languages,
    required this.experienceYears,
    required this.ratePerMinute,
    required this.rating,
    required this.totalReviews,
    required this.isOnline,
    required this.isBusy,
    required this.bio,
    required this.avatarUrl,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      experienceYears: json['experience_years'] ?? 1,
      ratePerMinute: (json['rate_per_minute'] as num?)?.toDouble() ?? 20.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: json['total_reviews'] ?? 0,
      isOnline: json['is_online'] ?? true,
      isBusy: json['is_busy'] ?? false,
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}
