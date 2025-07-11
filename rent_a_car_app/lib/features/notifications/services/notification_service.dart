import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';

/// Serviço responsável por todas as operações relacionadas às notificações
class NotificationService {
  static const String _baseRoute = '/notification';

  /// Busca todas as notificações do usuário
  static Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final userId = _getUserIdFromToken(token);
      if (userId == null) {
        throw Exception('Não foi possível identificar o usuário');
      }

      final response = await http.get(
        Uri.parse('$baseUrl$_baseRoute/notifications?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => NotificationItem.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao buscar notificações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar notificações: $e');
    }
  }

  /// Marca uma notificação como lida
  static Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl$_baseRoute/notifications/$notificationId/read'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar como lida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao marcar como lida: $e');
    }
  }

  /// Deleta uma notificação
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$_baseRoute/notifications/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao deletar notificação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar notificação: $e');
    }
  }

  /// Deleta múltiplas notificações
  static Future<void> deleteMultipleNotifications(
    List<String> notificationIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      // Deleta uma por uma (você pode implementar uma rota em lote no backend)
      for (final id in notificationIds) {
        await deleteNotification(id);
      }
    } catch (e) {
      throw Exception('Erro ao deletar notificações: $e');
    }
  }

  /// Extrai o ID do usuário do token JWT
  static String? _getUserIdFromToken(String? token) {
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );

      final Map<String, dynamic> jsonPayload = json.decode(payload);
      return jsonPayload['sub'];
    } catch (e) {
      return null;
    }
  }
}
