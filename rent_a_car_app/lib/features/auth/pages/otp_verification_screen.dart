import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_a_car_app/features/cars/pages/home_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/login.dart';
import '../../../fcm_initializer.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String? deviceId;
  final bool isLoginOtp;
  final String? infoMessage; // Novo parâmetro opcional

  const OTPVerificationScreen({
    Key? key,
    required this.email,
    this.deviceId,
    this.isLoginOtp = false,
    this.infoMessage,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  Future<void> _verifyOtp(String pin) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      final endpoint = widget.isLoginOtp ? '/auth/verify-otp' : '/auth/confirm-signup';
      final response = await api.post(endpoint, {
        'email': widget.email,
        'otp': pin,
        if (widget.deviceId != null) 'deviceId': widget.deviceId,
      });
      print('Resposta OTP: [32m${response.data}[0m');
      print('Status: ${response.statusCode}');
      final responseData = response.data;
      final token = responseData['token'];
      if (response.statusCode == 200 && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await initFCM(context); // <-- Adicionado para garantir envio do deviceToken
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else if (response.statusCode == 200 && token == null && !widget.isLoginOtp) {
        // Cadastro ativado, mas sem token: mostrar mensagem e ir para login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta ativada! Faça login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print('Token não encontrado na resposta');
        _showErrorDialog();
      }
    } catch (e) {
      print('Erro na verificação: $e');
      _showErrorDialog(message: 'Erro ao verificar código.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPinCompleted(String pin) {
    if (pin.length == 6) {
      _verifyOtp(pin);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = ApiService();
      final response = await api.post('/auth/resend-otp', {
        'email': widget.email,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Novo código enviado para o seu email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao reenviar código'),
            backgroundColor: Colors.red,
          ),
        );
  }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao reenviar código'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Substituiçõa do método _showSuccessDialog() por:
  void _navigateToHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código verificado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Aguarda um momento e navega para Home
    Future.delayed(const Duration(milliseconds: 1500), () {
      // Remove todas as telas anteriores e navega para Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  void _showErrorDialog({String message = 'Código inválido. Tente novamente.'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pinController.clear();
              _focusNode.requestFocus();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
        border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Koila',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.infoMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.infoMessage!,
                  style: const TextStyle(color: Colors.orange, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 40),
            const Text(
              'Inserir código de verificação',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enviamos um código para: ${_maskEmail(widget.email)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (widget.isLoginOtp)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Confirme seu e-mail para acessar sua conta.',
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
              ),
            if (!widget.isLoginOtp)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Finalize seu cadastro confirmando o e-mail.',
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
              ),
            const SizedBox(height: 40),
            Center(
              child: Pinput(
                controller: _pinController,
                focusNode: _focusNode,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: _onPinCompleted,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não recebeu o OTP? ',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _resendOTP,
                    child: const Text(
                      'Reenviar.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(
                child: Text(
                  'A verificar código...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
