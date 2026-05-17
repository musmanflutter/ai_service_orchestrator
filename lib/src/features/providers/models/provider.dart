class ServiceProvider {
  final String id;
  final String name;
  final String category; // e.g. "AC Technician", "Plumber", "Electrician"
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int basePrice;
  final double cancellationRate; // 0.0 to 1.0 (lower is better)

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.basePrice,
    required this.cancellationRate,
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
      'cancellationRate': cancellationRate,
    };
  }
}
