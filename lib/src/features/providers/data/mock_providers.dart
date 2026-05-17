import '../models/provider.dart';

final List<ServiceProvider> mockProviders = [
  // AC TECHNICIANS
  ServiceProvider(
    id: 'p1',
    name: 'Ali AC Services',
    category: 'AC Technician',
    rating: 4.9,
    reviewCount: 120,
    distanceKm: 2.1,
    basePrice: 1500,
    cancellationRate: 0.0, // Highly reliable
  ),
  ServiceProvider(
    id: 'p2',
    name: 'Tariq Cooling Experts',
    category: 'AC Technician',
    rating: 4.5,
    reviewCount: 85,
    distanceKm: 1.2,
    basePrice: 1200,
    cancellationRate: 0.05,
  ),
  ServiceProvider(
    id: 'p3',
    name: 'Bilal AC Repair',
    category: 'AC Technician',
    rating: 3.8,
    reviewCount: 30,
    distanceKm: 5.5,
    basePrice: 1000,
    cancellationRate: 0.25, // High cancellation risk
  ),

  // PLUMBERS
  ServiceProvider(
    id: 'p4',
    name: 'Imran Plumbers',
    category: 'Plumber',
    rating: 4.8,
    reviewCount: 200,
    distanceKm: 3.0,
    basePrice: 800,
    cancellationRate: 0.02,
  ),
  ServiceProvider(
    id: 'p5',
    name: 'Karachi Quick Fix Plumbing',
    category: 'Plumber',
    rating: 4.2,
    reviewCount: 45,
    distanceKm: 0.8,
    basePrice: 1000,
    cancellationRate: 0.10,
  ),

  // ELECTRICIANS
  ServiceProvider(
    id: 'p6',
    name: 'Zafar Electric',
    category: 'Electrician',
    rating: 4.7,
    reviewCount: 150,
    distanceKm: 4.2,
    basePrice: 1200,
    cancellationRate: 0.01,
  ),
  ServiceProvider(
    id: 'p7',
    name: 'Asad Wire Works',
    category: 'Electrician',
    rating: 4.0,
    reviewCount: 22,
    distanceKm: 1.5,
    basePrice: 900,
    cancellationRate: 0.15, // Unreliable
  ),
];
