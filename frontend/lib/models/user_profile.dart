class UserProfile {
  final String id;
  final String phone;
  final String fullName;
  final String gender;
  final String dob;
  final String tob;
  final String pobCity;
  final String pobCountry;
  final double walletBalance;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.tob,
    required this.pobCity,
    required this.pobCountry,
    required this.walletBalance,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserProfile(
        id: '',
        phone: '',
        fullName: 'Devotee',
        gender: 'male',
        dob: '',
        tob: '',
        pobCity: '',
        pobCountry: 'India',
        walletBalance: 0.0,
        avatarUrl: '',
      );
    }
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? 'Devotee',
      gender: json['gender']?.toString() ?? 'male',
      dob: json['dob']?.toString() ?? '',
      tob: json['tob']?.toString() ?? '',
      pobCity: json['pob_city'] ?? json['pobCity'] ?? '',
      pobCountry: json['pob_country'] ?? json['pobCountry'] ?? 'India',
      walletBalance: (json['wallet_balance'] ?? json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'gender': gender,
      'dob': dob,
      'tob': tob,
      'pob_city': pobCity,
      'pob_country': pobCountry,
      'wallet_balance': walletBalance,
      'avatar_url': avatarUrl,
    };
  }
}
