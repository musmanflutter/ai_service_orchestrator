class Provider {
  final String id;
  final String name;
  final String serviceType;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final String availability;
  final int reliabilityScore;
  final int cancellationRate;
  final double priceMultiplier;
  final int experienceYears;
  final String specialization;
  final List<String> languages;
  final int completedJobs;
  final int basePrice;
  final bool isAvailable;

  const Provider({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.availability,
    required this.reliabilityScore,
    required this.cancellationRate,
    required this.priceMultiplier,
    required this.experienceYears,
    required this.specialization,
    required this.languages,
    required this.completedJobs,
    required this.basePrice,
    required this.isAvailable,
  });

  factory Provider.fromMap(Map<String, dynamic> map) {
    return Provider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      serviceType: map['serviceType'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      availability: map['availability'] ?? '',
      reliabilityScore: map['reliabilityScore'] ?? 0,
      cancellationRate: map['cancellationRate'] ?? 0,
      priceMultiplier: (map['priceMultiplier'] ?? 1).toDouble(),
      experienceYears: map['experienceYears'] ?? 0,
      specialization: map['specialization'] ?? '',
      languages: List<String>.from(map['languages'] ?? []),
      completedJobs: map['completedJobs'] ?? 0,
      basePrice: map['basePrice'] ?? 0,
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'rating': rating,
      'reviewCount': reviewCount,
      'distanceKm': distanceKm,
      'availability': availability,
      'reliabilityScore': reliabilityScore,
      'cancellationRate': cancellationRate,
      'priceMultiplier': priceMultiplier,
      'experienceYears': experienceYears,
      'specialization': specialization,
      'languages': languages,
      'completedJobs': completedJobs,
      'basePrice': basePrice,
      'isAvailable': isAvailable,
    };
  }
}
