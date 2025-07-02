import 'package:rent_a_car_app/models/rental_history.dart';

class HistoryService {
  static Future<List<RentalHistory>> getHistory() async {
    // Simulação temporária
    return [];
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    return {'totalTrips': 0, 'totalSpent': 0};
  }
}
