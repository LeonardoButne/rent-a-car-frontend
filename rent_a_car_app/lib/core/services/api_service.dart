import 'package:dio/dio.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? headers}) async {
    return await _dio.get(path, options: Options(headers: headers));
  }

  Future<Response> post(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    return await _dio.post(path, data: data, options: Options(headers: headers));
  }

  Future<Response> patch(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    return await _dio.patch(path, data: data, options: Options(headers: headers));
  }

  Future<Response> delete(String path, {Map<String, dynamic>? headers}) async {
    return await _dio.delete(path, options: Options(headers: headers));
  }
}
