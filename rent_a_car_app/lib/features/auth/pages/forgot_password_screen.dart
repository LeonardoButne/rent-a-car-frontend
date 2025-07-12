import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/forgot_password_service.dart';
import 'package:rent_a_car_app/features/auth/widgets/forgot_password_helpers.dart';
import 'package:rent_a_car_app/features/auth/widgets/forgot_password_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _sendResetEmail() async {
    // Validação local
    final emailError = ForgotPasswordHelpers.validateEmail(
      _emailController.text,
    );
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ForgotPasswordService.sendResetEmail(
      _emailController.text,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _emailSent = true;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    });

    if (result['success']) {
      ForgotPasswordHelpers.showFeedback(
        context,
        'Email de recuperação enviado com sucesso!',
      );
    }
  }

  void _goBackToLogin() {
    Navigator.pop(context);
  }

  void _tryAgain() {
    setState(() {
      _emailSent = false;
      _errorMessage = null;
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo e nome da app
                    const ForgotPasswordHeader(),

                    const SizedBox(height: 60),

                    // Título e descrição
                    const ForgotPasswordTitle(),

                    const SizedBox(height: 40),

                    if (_emailSent) ...[
                      // Estado de sucesso
                      SuccessMessage(email: _emailController.text),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: 'Voltar ao Login',
                        onPressed: _goBackToLogin,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SecondaryButton(
                          text: 'Tentar outro email',
                          onPressed: _tryAgain,
                        ),
                      ),
                    ] else ...[
                      // Formulário principal
                      EmailInputField(
                        controller: _emailController,
                        errorMessage: _errorMessage,
                      ),

                      const SizedBox(height: 24),

                      // Botão enviar
                      PrimaryButton(
                        text: 'Enviar Link',
                        onPressed: _sendResetEmail,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Link voltar ao login
                      Center(
                        child: SecondaryButton(
                          text: 'Voltar ao login',
                          onPressed: _goBackToLogin,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Texto inferior (como nas outras telas)
                    if (!_emailSent) ...[
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lembrou da senha? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _goBackToLogin,
                              child: const Text(
                                'Entrar.',
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
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
