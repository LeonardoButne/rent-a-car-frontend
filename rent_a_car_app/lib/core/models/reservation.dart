class Reservation {
  final String id;
  final String carId;
  final String ownerId;
  final String? clientId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReservationCar? car;
  final ReservationOwner? owner;

  Reservation({
    required this.id,
    required this.carId,
    required this.ownerId,
    this.clientId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.car,
    this.owner,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    return Reservation(
      id: json['id'],
      carId: json['carId'],
      ownerId: json['ownerId'],
      clientId: json['clientId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      price: parsePrice(json['price']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      car: json['car'] != null ? ReservationCar.fromJson(json['car']) : null,
      owner: json['owner'] != null ? ReservationOwner.fromJson(json['owner']) : null,
    );
  }
}

class ReservationCar {
  final String id;
  final String marca;
  final String modelo;
  final String placa;
  final String cor;
  final int ano;
  final List<CarImage> images;
  ReservationCar({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.cor,
    required this.ano,
    required this.images,
  });
  factory ReservationCar.fromJson(Map<String, dynamic> json) {
    return ReservationCar(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      placa: json['placa'],
      cor: json['cor'],
      ano: json['ano'],
      images: (json['images'] as List?)?.map((img) {
        if (img is String) {
          return CarImage(url: img, id: '', fileName: '', originalName: '');
        } else if (img is Map<String, dynamic>) {
          return CarImage.fromJson(img);
        } else {
          return CarImage(url: '', id: '', fileName: '', originalName: '');
        }
      }).toList() ?? [],
    );
  }
}

class CarImage {
  final String url;
  final String id;
  final String fileName;
  final String originalName;
  CarImage({
    required this.url,
    required this.id,
    required this.fileName,
    required this.originalName,
  });
  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      url: json['url'],
      id: json['id'],
      fileName: json['fileName'],
      originalName: json['originalName'],
    );
  }
}

class ReservationOwner {
  final String id;
  final String name;
  final String lastName;
  final String email;
  ReservationOwner({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
  });
  factory ReservationOwner.fromJson(Map<String, dynamic> json) {
    return ReservationOwner(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
} 