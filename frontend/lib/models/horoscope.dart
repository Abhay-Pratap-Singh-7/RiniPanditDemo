class Horoscope {
  final String sign;
  final String luckyColor;
  final int luckyNumber;
  final double rating;
  final String prediction;

  Horoscope({
    required this.sign,
    required this.luckyColor,
    required this.luckyNumber,
    required this.rating,
    required this.prediction,
  });

  factory Horoscope.fromJson(String sign, Map<String, dynamic> json) {
    return Horoscope(
      sign: sign,
      luckyColor: json['luckyColor'] ?? 'Gold',
      luckyNumber: json['luckyNumber'] ?? 7,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      prediction: json['prediction'] ?? '',
    );
  }
}
