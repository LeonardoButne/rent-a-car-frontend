import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationItem>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = _fetchNotifications();
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = _getUserIdFromToken(token);
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar notificações');
    }
  }

  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    // Decodifique o JWT para pegar o sub/userId
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> jsonPayload = json.decode(payload);
    return jsonPayload['sub'];
  }

  Future<void> _markAsRead(String notificationId, String token) async {
    await http.patch(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  void _onNotificationTap(NotificationItem notification) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    await _markAsRead(notification.id, token!);
    if (notification.type == 'reservation_request') {
      Navigator.pushNamed(context, '/owner-reservations', arguments: notification.reservationId);
    } else {
      Navigator.pushNamed(context, '/my-reservations', arguments: notification.reservationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder<List<NotificationItem>>(
              future: _futureNotifications,
              builder: (context, snapshot) {
                final notifications = snapshot.data ?? [];
                final unreadCount = notifications.where((n) => !n.isRead).length;
                return _buildHeader(context, unreadCount);
              },
            ),
            Expanded(
              child: FutureBuilder<List<NotificationItem>>(
                future: _futureNotifications,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar notificações'));
                  }
                  final notifications = snapshot.data ?? [];
                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return ListTile(
                        title: Text(n.title),
                        subtitle: Text(n.message),
                        trailing: n.isRead ? null : Icon(Icons.fiber_new, color: Colors.red),
                        onTap: () => _onNotificationTap(n),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
          ),
          const Expanded(
            child: Text(
              'Notificações',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.more_horiz, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.notifications_none, size: 60, color: Colors.grey[400]),
              Positioned(
                top: 15,
                right: 25,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'NENHUMA NOTIFICAÇÃO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tudo limpo. Nós iremos notificá-lo\nquando houver algo novo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
