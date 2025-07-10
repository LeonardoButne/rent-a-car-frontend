import 'dart:ui';

enum RentalStatus {
  completed, // Concluído
  cancelled, // Cancelado
  ongoing, // Em andamento
  rejected, // Rejeitado
}

/// Modelo para histórico de aluguel
class RentalHistory {
  final String id;
  final String carName;
  final String carBrand;
  final String carImage;
  final DateTime startDate;
  final DateTime endDate;
  final double totalValue;
  final RentalStatus status;
  final double? userRating; // Avaliação dada pelo usuário
  final int totalDays;
  final String ownerId;
  final String clientName;
  final String clientEmail;

  RentalHistory({
    required this.id,
    required this.carName,
    required this.carBrand,
    required this.carImage,
    required this.startDate,
    required this.endDate,
    required this.totalValue,
    required this.status,
    this.userRating,
    required this.totalDays,
    required this.ownerId,
    required this.clientName,
    required this.clientEmail,
  });

  /// Cria instância a partir do JSON da API
  factory RentalHistory.fromJson(Map<String, dynamic> json) {
    final car = json['car'] ?? {};
    final images = (car['images'] as List?) ?? [];
    final carImage = images.isNotEmpty ? images[0]['url'] ?? '' : '';
    final startDate = DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String());
    final endDate = DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String());
    final client = json['client'] ?? {};
    return RentalHistory(
      id: json['id']?.toString() ?? '',
      carName: car['modelo'] ?? '',
      carBrand: car['marca'] ?? '',
      carImage: carImage,
      startDate: startDate,
      endDate: endDate,
      totalValue: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: _parseStatus(json['status']),
      userRating: null, // Não há avaliação no JSON
      totalDays: endDate.difference(startDate).inDays,
      ownerId: json['ownerId'] ?? '',
      clientName: client['name'] ?? '',
      clientEmail: client['email'] ?? '',
    );
  }

  /// Converte para JSON para enviar à API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_name': carName,
      'car_brand': carBrand,
      'car_image': carImage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_value': totalValue,
      'status': status.name,
      'user_rating': userRating,
      'total_days': totalDays,
    };
  }

  /// Converte string do status para enum
  static RentalStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return RentalStatus.completed;
      case 'cancelled':
        return RentalStatus.cancelled;
      case 'ongoing':
        return RentalStatus.ongoing;
      case 'rejected':
        return RentalStatus.rejected;
      default:
        return RentalStatus.completed;
    }
  }

  /// Retorna cor baseada no status
  Color get statusColor {
    switch (status) {
      case RentalStatus.completed:
        return const Color(0xFF4CAF50); // Verde
      case RentalStatus.cancelled:
        return const Color(0xFFF44336); // Vermelho
      case RentalStatus.ongoing:
        return const Color(0xFF2196F3); // Azul
      case RentalStatus.rejected:
        return const Color(0xFFBDBDBD); // Cinza
    }
  }

  /// Retorna texto do status em português
  String get statusText {
    switch (status) {
      case RentalStatus.completed:
        return 'Concluído';
      case RentalStatus.cancelled:
        return 'Cancelado';
      case RentalStatus.ongoing:
        return 'Em andamento';
      case RentalStatus.rejected:
        return 'Rejeitado';
    }
  }
}
