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

  factory Astrologer.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Astrologer(
        id: '',
        displayName: 'Acharya',
        specialties: const ['Vedic', 'Kundli'],
        languages: const ['Hindi', 'English'],
        experienceYears: 5,
        ratePerMinute: 25.0,
        rating: 5.0,
        totalReviews: 0,
        isOnline: true,
        isBusy: false,
        bio: '',
        avatarUrl: '',
      );
    }

    double parseDouble(dynamic v, double fallback) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    int parseInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    return Astrologer(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? 'Acharya',
      specialties: json['specialties'] is List
          ? List<String>.from(json['specialties'])
          : const ['Vedic', 'Kundli'],
      languages: json['languages'] is List
          ? List<String>.from(json['languages'])
          : const ['Hindi', 'English'],
      experienceYears: parseInt(json['experience_years'] ?? json['experienceYears'], 5),
      ratePerMinute: parseDouble(json['rate_per_minute'] ?? json['ratePerMinute'], 25.0),
      rating: parseDouble(json['rating'], 5.0),
      totalReviews: parseInt(json['total_reviews'] ?? json['totalReviews'], 0),
      isOnline: json['is_online'] ?? json['isOnline'] ?? true,
      isBusy: json['is_busy'] ?? json['isBusy'] ?? false,
      bio: json['bio']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? '',
    );
  }
}
