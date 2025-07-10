import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchUnreadNotificationsCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        return Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, 0, unreadCount, context),
              _buildNavItem(Icons.inbox, 1, unreadCount, context), // Reservas
              _buildNotificationNavItem(2, unreadCount, context),
              _buildNavItem(Icons.person_outline, 3, unreadCount, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, int index, int unreadCount, BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: currentIndex == index ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNotificationNavItem(int index, int unreadCount, BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.notifications_outlined,
              color: currentIndex == index ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<int> _fetchUnreadNotificationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = _getUserIdFromToken(token);
    final response = await http.get(
      Uri.parse('$baseUrl/notification/notifications?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
      return notifications.where((n) => !n.isRead).length;
    } else {
      throw Exception('Erro ao buscar notificações');
    }
  }

  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> jsonPayload = json.decode(payload);
    return jsonPayload['sub'];
  }
} 