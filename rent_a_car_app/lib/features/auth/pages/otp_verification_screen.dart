import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
<<<<<<< HEAD
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
=======
import 'package:rent_a_car_app/features/auth/pages/home_screen.dart';
>>>>>>> aae64c443f1b89ea9cc6e8b3fea27c9038c59148

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLoginOtp;

<<<<<<< HEAD
  const OTPVerificationScreen({
    Key? key, 
    required this.email,
    this.isLoginOtp = false,
  }) : super(key: key);
=======
  const OTPVerificationScreen({super.key, required this.email});
>>>>>>> aae64c443f1b89ea9cc6e8b3fea27c9038c59148

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
      
      // Escolher endpoint baseado no tipo de OTP
      final endpoint = widget.isLoginOtp ? '/client/login/verify-otp' : '/client/signup/confirm';
      final payload = widget.isLoginOtp 
          ? {'email': widget.email, 'otp': pin}
          : {'email': widget.email, 'otp': pin};
      
      final response = await api.post(endpoint, payload);
      print('Resposta OTP: ${response.data}');
      print('Status: ${response.statusCode}');
      
      // Verificar se a resposta tem token
      final responseData = response.data;
      final token = responseData['token'];
      
      if (response.statusCode == 200 && token != null) {
        // Salvar token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // Navegar para tela principal
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
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

<<<<<<< HEAD
  void _onPinCompleted(String pin) {
    if (pin.length == 6) {
      _verifyOtp(pin);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
=======
      // verificação do OTP
      if (pin == "123456") {
        _navigateToHome();
      } else {
        _showErrorDialog();
      }
>>>>>>> aae64c443f1b89ea9cc6e8b3fea27c9038c59148
    });
    try {
      final api = ApiService();
      final response = await api.post('/client/resend-otp-client', {
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
              'Enviámos um código para: ${_maskEmail(widget.email)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_pinController.text.length == 6) {
                          _onPinCompleted(_pinController.text);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não recebeu o OTP? ',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _resendOTP,
                    child: const Text(
                      'Reenviar.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // loding na parte inferior
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
