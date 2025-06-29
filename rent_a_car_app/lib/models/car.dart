class Car {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double rating;
  final String location;
  final double pricePerDay;
  final int seats;
  final bool isAvailable;
  final String category;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.rating,
    required this.location,
    required this.pricePerDay,
    required this.seats,
    this.isAvailable = true,
    required this.category,
  });
}
