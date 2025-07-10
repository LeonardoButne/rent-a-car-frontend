import 'package:rent_a_car_app/models/rental_history.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HistoryService {
  static final ApiService _api = ApiService();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<RentalHistory>> getHistory() async {
    final token = await _getToken();
    // Buscar tipo de conta do token
    String typeAccount = '';
    if (token != null && token.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = JwtDecoder.decode(token);
        typeAccount = decoded['typeAccount'] ?? '';
      } catch (_) {}
    }
    final endpoint = typeAccount == 'owner'
        ? '/owner/reservations'
        : '/client/reservations/my';
    final response = await _api.get(
      endpoint,
      headers: {'Authorization': 'Bearer $token'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => RentalHistory.fromJson(json)).toList();
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    // Você pode implementar um endpoint real para estatísticas se desejar
    return {'totalTrips': 0, 'totalSpent': 0};
  }
}
