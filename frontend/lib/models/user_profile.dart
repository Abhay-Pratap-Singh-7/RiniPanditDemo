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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? 'Devotee',
      gender: json['gender'] ?? 'male',
      dob: json['dob'] ?? '',
      tob: json['tob'] ?? '',
      pobCity: json['pob_city'] ?? '',
      pobCountry: json['pob_country'] ?? 'India',
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: json['avatar_url'] ?? '',
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
