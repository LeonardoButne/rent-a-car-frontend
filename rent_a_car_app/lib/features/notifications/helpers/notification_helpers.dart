import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

/// Classe para agrupar notificações por período
class NotificationGrouper {
  static Map<String, List<NotificationItem>> groupByPeriod(
    List<NotificationItem> notifications,
  ) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationItem>> grouped = {
      'Hoje': [],
      'Ontem': [],
      'Anteriores': [],
    };

    for (final notification in notifications) {
      if (_isSameDay(notification.createdAt, today)) {
        grouped['Hoje']!.add(notification);
      } else if (_isSameDay(notification.createdAt, yesterday)) {
        grouped['Ontem']!.add(notification);
      } else {
        grouped['Anteriores']!.add(notification);
      }
    }

    // Remove seções vazias
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;
  }
}

/// Classe para mostrar diálogos relacionados às notificações
class NotificationDialogs {
  /// Mostra diálogo de confirmação para deletar notificações
  static Future<bool> showDeleteConfirmation(
    BuildContext context,
    int count,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deletar Notificações'),
        content: Text(
          'Tem certeza que deseja deletar $count notificação${count > 1 ? 'ões' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

/// Classe para mostrar mensagens de feedback
class NotificationFeedback {
  /// Mostra mensagem de sucesso
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Mostra mensagem de erro
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

/// Classe para navegação baseada no tipo de notificação
class NotificationNavigator {
  static void navigateToTarget(
    BuildContext context,
    NotificationItem notification,
  ) {
    switch (notification.type) {
      case 'reservation_request':
        Navigator.pushNamed(
          context,
          '/owner-reservations',
          arguments: notification.reservationId,
        );
        break;
      case 'payment':
      case 'pickup':
      case 'return':
      case 'cancellation':
      case 'reservation_approved':
      case 'reservation_rejected':
        // Marcar todas as notificações relacionadas a reservas como lidas
        _markReservationNotificationsAsRead(context);
        Navigator.pushNamed(
          context,
          '/my-reservations',
          arguments: notification.reservationId,
        );
        break;
      case 'discount':
        break;
      default:
        // Não navega para lugar nenhum
        break;
    }
  }

  /// Marca todas as notificações relacionadas a reservas como lidas
  static Future<void> _markReservationNotificationsAsRead(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return;

      final userId = _getUserIdFromToken(token);
      if (userId == null) return;

      // Buscar todas as notificações não lidas relacionadas a reservas
      final response = await http.get(
        Uri.parse('$baseUrl/notification/notifications?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final List<NotificationItem> notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
        
        // Filtrar notificações não lidas relacionadas a reservas
        final reservationNotificationTypes = [
          'payment', 'pickup', 'return', 'cancellation', 
          'reservation_approved', 'reservation_rejected'
        ];
        
        final unreadReservationNotifications = notifications.where((n) => 
          !n.isRead && reservationNotificationTypes.contains(n.type)
        ).toList();

        // Marcar todas como lidas
        for (final notification in unreadReservationNotifications) {
          await http.patch(
            Uri.parse('$baseUrl/notification/notifications/${notification.id}/read'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }
    } catch (e) {
      // Silenciosamente ignora erros para não interromper a navegação
      print('Erro ao marcar notificações como lidas: $e');
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
