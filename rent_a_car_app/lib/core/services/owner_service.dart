import 'dart:io';
import 'package:rent_a_car_app/core/models/owner.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class OwnerService {
  static final ApiService _api = ApiService();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 1. Cadastro de Owner
  static Future<void> signupOwner(Map<String, dynamic> data) async {
    await _api.post('/owner/signup', data);
  }

  // 2. Confirmação de Cadastro (OTP)
  static Future<Map<String, dynamic>> confirmSignupOwner(String email, String otp) async {
    final response = await _api.post('/owner/signup/confirm', {
      'email': email,
      'otp': otp,
    });
    return response.data;
  }

  // 3. Login
  static Future<void> loginOwner(String email, String password) async {
    await _api.post('/owner/login', {
      'email': email,
      'password': password,
    });
  }

  // 4. Confirmação de Login (OTP)
  static Future<Map<String, dynamic>> confirmLoginOwner(String email, String otp) async {
    final response = await _api.post('/owner/login/verify-otp', {
      'email': email,
      'otp': otp,
    });
    return response.data;
  }

  // 5. Recuperar Conta do Owner
  static Future<Owner> getOwnerAccount() async {
    final token = await _getToken();
    final response = await _api.get('/owner/account', headers: {'Authorization': 'Bearer $token'});
    return Owner.fromJson(response.data);
  }

  // 6a. Criar Carro (form-data)
  static Future<OwnerCar> createCar(Map<String, dynamic> data, List<File> images) async {
    final token = await _getToken();
    final formData = FormData.fromMap(data);
    for (var img in images) {
      final mimeType = lookupMimeType(img.path) ?? 'image/jpeg';
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      ));
    }
    final response = await _api.post('/owner/create/car', formData, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });
    return OwnerCar.fromJson(response.data);
  }

  // 6b. Listar Meus Carros
  static Future<List<OwnerCar>> getMyCars() async {
    final token = await _getToken();
    final response = await _api.get('/owner/my-cars', headers: {'Authorization': 'Bearer $token'});
    final List<dynamic> data = response.data;
    return data.map((json) => OwnerCar.fromJson(json)).toList();
  }

  // 6c. Atualizar Carro (form-data)
  static Future<OwnerCar> updateCar(String carId, Map<String, dynamic> data, [List<File>? newImages]) async {
    final token = await _getToken();
    final formData = FormData.fromMap(data);
    if (newImages != null) {
      for (var img in newImages) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(img.path, filename: img.path.split('/').last)));
      }
    }
    final response = await _api.patch('/owner/car/$carId', formData, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });
    return OwnerCar.fromJson(response.data);
  }

  // 6d. Deletar Carro
  static Future<void> deleteCar(String carId) async {
    final token = await _getToken();
    await _api.delete('/owner/car/$carId', headers: {'Authorization': 'Bearer $token'});
  }

  // 6e. Deletar Imagem do Carro
  static Future<void> deleteCarImage(String carId, String imageId) async {
    final token = await _getToken();
    await _api.delete('/owner/car/$carId/image/$imageId', headers: {'Authorization': 'Bearer $token'});
  }

  // 7. Listar Reservas dos Meus Carros
  static Future<List<OwnerReservation>> getOwnerReservations() async {
    final token = await _getToken();
    final response = await _api.get('/owner/reservations', headers: {'Authorization': 'Bearer $token'});
    final List<dynamic> data = response.data;
    return data.map((json) => OwnerReservation.fromJson(json)).toList();
  }

  // 8. Aprovar ou Rejeitar Reserva
  static Future<void> updateReservationStatus(String reservationId, String status) async {
    final token = await _getToken();
    await _api.patch('/owner/reservations/$reservationId', {'status': status}, headers: {'Authorization': 'Bearer $token'});
  }

  // 8. Aprovar Reserva
  static Future<void> approveReservation(String reservationId) async {
    final token = await _getToken();
    await _api.patch('/owner/reservations/$reservationId/approve', {}, headers: {'Authorization': 'Bearer $token'});
  }

  // 9. Rejeitar Reserva
  static Future<void> rejectReservation(String reservationId) async {
    final token = await _getToken();
    await _api.patch('/owner/reservations/$reservationId/reject', {}, headers: {'Authorization': 'Bearer $token'});
  }
} 