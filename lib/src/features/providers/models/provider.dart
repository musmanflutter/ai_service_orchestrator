class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int basePrice;
  final int maxPrice;
  final double cancellationRate;
  final List<String> tags; // e.g. ["Top Rated", "Fast Response"]
  final String avatarEmoji; // e.g. "👨‍🔧"

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.basePrice,
    this.maxPrice = 0,
    this.cancellationRate = 0.0,
    this.tags = const [],
    this.avatarEmoji = '👨‍🔧',
  });

  // Helpful for when we feed this data into the Gemini Prompt
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'distanceKm': distanceKm,
      'basePrice': basePrice,
      'maxPrice': maxPrice > 0 ? maxPrice : basePrice + 500,
      'cancellationRate': cancellationRate,
      'tags': tags,
    };
  }

  // Reliability as a percentage string
  String get reliabilityPercent =>
      '${((1 - cancellationRate) * 100).toStringAsFixed(0)}%';
}
