class Booking {
  final String bookingId;
  final String providerId;
  final String providerName;
  final String serviceType;
  final String location;
  final String scheduledTime;
  final String status;
  final int price;
  final DateTime createdAt;

  const Booking({
    required this.bookingId,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.location,
    required this.scheduledTime,
    required this.status,
    required this.price,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookingId: map['bookingId'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      serviceType: map['serviceType'] ?? '',
      location: map['location'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      status: map['status'] ?? '',
      price: map['price'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'providerId': providerId,
      'providerName': providerName,
      'serviceType': serviceType,
      'location': location,
      'scheduledTime': scheduledTime,
      'status': status,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
