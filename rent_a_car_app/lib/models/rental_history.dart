import 'dart:ui';

enum RentalStatus {
  completed, // Concluído
  cancelled, // Cancelado
  ongoing, // Em andamento
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
  });

  /// Cria instância a partir do JSON da API
  factory RentalHistory.fromJson(Map<String, dynamic> json) {
    return RentalHistory(
      id: json['id']?.toString() ?? '',
      carName: json['car_name'] ?? '',
      carBrand: json['car_brand'] ?? '',
      carImage: json['car_image'] ?? '',
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      totalValue: (json['total_value'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      userRating: json['user_rating']?.toDouble(),
      totalDays: json['total_days'] ?? 0,
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
    }
  }
}
