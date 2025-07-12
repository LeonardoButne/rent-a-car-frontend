import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:dio/dio.dart';

class ForgotPasswordService {
  /// Envia email de recuperação de senha
  static Future<Map<String, dynamic>> sendResetEmail(String email) async {
    try {
      final api = ApiService();
      final response = await api.post('/auth/forgot-password', {
        'email': email.trim(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Email de recuperação enviado com sucesso',
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao enviar email de recuperação',
        };
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      return {
        'success': false,
        'message': data != null && data['error'] != null
            ? data['error']
            : 'Email não encontrado ou inválido',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão. Tente novamente.'};
    }
  }
}
