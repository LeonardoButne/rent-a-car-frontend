import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/login.dart';
import 'package:rent_a_car_app/features/cars/pages/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rent_a_car_app/features/notifications/pages/notification_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/my_reservations_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/profile_screen.dart';
import 'package:rent_a_car_app/features/owner/pages/owner_reservations_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
    print('BASE_URL carregado: ${dotenv.env['BASE_URL']}');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => HomeScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/my-reservations': (context) => MyReservationsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/owner-reservations': (context) => OwnerReservationsScreen(),
        // Adicione a rota de notificações se necessário
      },
      navigatorKey: navigatorKey, // Para navegação via push
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Removido _initFCM e qualquer referência a notificações

  Future<void> _checkAuthStatus() async {
    // Aguarda um pouco para mostrar a tela de splash
    await Future.delayed(Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Token existe, navegar para Home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Não há token, navegar para Login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Koila',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Rent a Car',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
