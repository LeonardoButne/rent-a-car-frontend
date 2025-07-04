import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  static final ApiService _api = ApiService();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Reservation> createReservation({
    required String carId,
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final token = await _getToken();
    final response = await _api.post(
      '/client/reservations',
      {
        'carId': carId,
        'ownerId': ownerId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  static Future<List<Reservation>> getMyReservations() async {
    final token = await _getToken();
    final response = await _api.get(
      '/client/reservations/my',
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  static Future<Reservation> getReservationById(String reservationId) async {
    final token = await _getToken();
    final response = await _api.get(
      '/client/reservations/$reservationId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  static Future<void> cancelReservation(String reservationId) async {
    final token = await _getToken();
    await _api.delete(
      '/client/reservations/$reservationId',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<Reservation> editReservation({
    required String reservationId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    final token = await _getToken();
    final response = await _api.patch(
      '/client/reservations/$reservationId',
      {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }
} 



/* apreciar
  
  //  NOVOS MÉTODOS (Proprietário)
  

  /// Busca todas as reservas solicitadas para os carros do proprietário
  static Future<List<Reservation>> getRequestedReservations() async {
    final token = await _getToken();
    final response = await _api.get(
      '/owner/reservations/requested',
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  /// Busca detalhes de uma reserva solicitada específica
  static Future<Reservation> getRequestedReservationById(String reservationId) async {
    final token = await _getToken();
    final response = await _api.get(
      '/owner/reservations/$reservationId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  /// Aprova uma reserva pendente
  static Future<Reservation> approveReservation(String reservationId) async {
    final token = await _getToken();
    final response = await _api.patch(
      '/owner/reservations/$reservationId/approve',
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  /// Rejeita uma reserva pendente
  static Future<Reservation> rejectReservation(String reservationId, {String? reason}) async {
    final token = await _getToken();
    final response = await _api.patch(
      '/owner/reservations/$reservationId/reject',
      {
        if (reason != null) 'reason': reason,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  /// Busca estatísticas de reservas para o proprietário
  static Future<Map<String, dynamic>> getOwnerReservationStats() async {
    final token = await _getToken();
    final response = await _api.get(
      '/owner/reservations/stats',
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.data;
  }

  /// Busca reservas por status específico (para proprietário)
  static Future<List<Reservation>> getRequestedReservationsByStatus(String status) async {
    final token = await _getToken();
    final response = await _api.get(
      '/owner/reservations/requested?status=$status',
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  /// Busca reservas de um carro específico (para proprietário)
  static Future<List<Reservation>> getCarReservations(String carId) async {
    final token = await _getToken();
    final response = await _api.get(
      '/owner/cars/$carId/reservations',
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  /// Atualiza status de uma reserva com observações (proprietário)
  static Future<Reservation> updateReservationStatus({
    required String reservationId,
    required String status,
    String? notes,
  }) async {
    final token = await _getToken();
    final response = await _api.patch(
      '/owner/reservations/$reservationId/status',
      {
        'status': status,
        if (notes != null) 'notes': notes,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  /// Marca reserva como concluída (após devolução do carro)
  static Future<Reservation> completeReservation(String reservationId, {
    String? notes,
    double? finalKilometers,
    bool? hasConditionalComments,
  }) async {
    final token = await _getToken();
    final response = await _api.patch(
      '/owner/reservations/$reservationId/complete',
      {
        if (notes != null) 'notes': notes,
        if (finalKilometers != null) 'finalKilometers': finalKilometers,
        if (hasConditionalComments != null) 'hasConditionalComments': hasConditionalComments,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  // ===========================
  //  MÉTODOS UTILITÁRIOS
  // ===========================

  /// Calcula o valor total da reserva baseado nas datas
  static double calculateReservationPrice({
    required DateTime startDate,
    required DateTime endDate,
    required double dailyPrice,
    required double weeklyPrice,
    required double monthlyPrice,
  }) {
    final days = endDate.difference(startDate).inDays;
    
    if (days >= 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      return (months * monthlyPrice) + (remainingDays * dailyPrice);
    } else if (days >= 7) {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;
      return (weeks * weeklyPrice) + (remainingDays * dailyPrice);
    } else {
      return days * dailyPrice;
    }
  }

  /// Verifica se as datas da reserva são válidas
  static bool isReservationDateValid({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    return startDate.isAfter(now) && endDate.isAfter(startDate);
  }

  /// Formata período da reserva para exibição
  static String formatReservationPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final days = endDate.difference(startDate).inDays;
    if (days == 1) {
      return '1 dia';
    } else if (days < 7) {
      return '$days dias';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;
      if (remainingDays == 0) {
        return weeks == 1 ? '1 semana' : '$weeks semanas';
      } else {
        return '$weeks semana${weeks > 1 ? 's' : ''} e $remainingDays dia${remainingDays > 1 ? 's' : ''}';
      }
    } else {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      if (remainingDays == 0) {
        return months == 1 ? '1 mês' : '$months meses';
      } else {
        return '$months mês${months > 1 ? 'es' : ''} e $remainingDays dia${remainingDays > 1 ? 's' : ''}';
      }
    }
  }
}*/