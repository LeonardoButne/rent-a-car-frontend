import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

Future<void> initFCM(BuildContext context) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Solicitar permissão para notificações
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permissão de notificações concedida!');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('Permissão de notificações negada!');
  } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    print('Permissão de notificações não determinada!');
  }
  String? token = await messaging.getToken();
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken != null && authToken.isNotEmpty) {
      await http.post(
        Uri.parse('$baseUrl/device-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'deviceToken': token}),
      );
    }
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final snackBar = SnackBar(
        content: Text(message.notification!.title ?? 'Nova notificação'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;
    final reservationId = data['reservationId'];
    final type = data['type'];
    if (type == 'reservation_request') {
      Navigator.pushNamed(context, '/owner-reservations', arguments: reservationId);
    } else {
      Navigator.pushNamed(context, '/my-reservations', arguments: reservationId);
    }
  });
}

Future<String?> getFcmToken() async {
  return await FirebaseMessaging.instance.getToken();
} 