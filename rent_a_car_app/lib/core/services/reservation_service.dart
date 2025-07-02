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
      'client/reservations',
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
      'client/reservations/my',
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  static Future<Reservation> getReservationById(String reservationId) async {
    final token = await _getToken();
    final response = await _api.get(
      'client/reservations/$reservationId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Reservation.fromJson(response.data);
  }

  static Future<void> cancelReservation(String reservationId) async {
    final token = await _getToken();
    await _api.delete(
      'client/reservations/$reservationId',
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
      'client/reservations/$reservationId',
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