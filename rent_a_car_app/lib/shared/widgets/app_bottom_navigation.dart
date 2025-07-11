import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({super.key, required this.currentIndex, required this.onTap});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotificationsCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza contador sempre que a tela for aberta/focada
    _fetchUnreadNotificationsCount();
  }

  @override
  void didUpdateWidget(AppBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza contador quando o widget é atualizado
    _fetchUnreadNotificationsCount();
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final userId = _getUserIdFromToken(token);
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/notification/notifications?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
        final unreadCount = notifications.where((n) => !n.isRead).length;
        
        if (mounted) {
          setState(() {
            _unreadCount = unreadCount;
          });
        }
      }
    } catch (e) {
      // Silenciosamente ignora erros para não interromper a navegação
      print('Erro ao buscar contador de notificações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, context),
          _buildNavItem(Icons.inbox, 1, context), // Reservas
          _buildNotificationNavItem(2, context),
          _buildNavItem(Icons.person_outline, 3, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: widget.currentIndex == index ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNotificationNavItem(int index, BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.notifications_outlined,
              color: widget.currentIndex == index ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          if (_unreadCount > 0)
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
                  '$_unreadCount',
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

  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> jsonPayload = json.decode(payload);
    return jsonPayload['sub'];
  }
} 