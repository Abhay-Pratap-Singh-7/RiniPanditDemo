class PlanetaryPosition {
  final String planet;
  final String sign;
  final String degree;
  final int house;
  final String status;

  PlanetaryPosition({
    required this.planet,
    required this.sign,
    required this.degree,
    required this.house,
    required this.status,
  });

  factory PlanetaryPosition.fromJson(Map<String, dynamic> json) {
    return PlanetaryPosition(
      planet: json['planet'] ?? '',
      sign: json['sign'] ?? '',
      degree: json['degree'] ?? '',
      house: json['house'] ?? 1,
      status: json['status'] ?? 'Direct',
    );
  }
}

class KundliResult {
  final String ascendant;
  final String moonSign;
  final String sunSign;
  final String nakshatra;
  final List<PlanetaryPosition> planetaryPositions;
  final bool manglik;
  final bool kaalSarp;
  final String remedy;
  final String prediction;

  KundliResult({
    required this.ascendant,
    required this.moonSign,
    required this.sunSign,
    required this.nakshatra,
    required this.planetaryPositions,
    required this.manglik,
    required this.kaalSarp,
    required this.remedy,
    required this.prediction,
  });

  factory KundliResult.fromJson(Map<String, dynamic> json) {
    return KundliResult(
      ascendant: json['ascendant'] ?? '',
      moonSign: json['moonSign'] ?? '',
      sunSign: json['sunSign'] ?? '',
      nakshatra: json['nakshatra'] ?? '',
      planetaryPositions: (json['planetaryPositions'] as List? ?? [])
          .map((p) => PlanetaryPosition.fromJson(p))
          .toList(),
      manglik: json['doshas']?['manglik'] ?? false,
      kaalSarp: json['doshas']?['kaalSarp'] ?? false,
      remedy: json['doshas']?['remedy'] ?? '',
      prediction: json['prediction'] ?? '',
    );
  }
}
