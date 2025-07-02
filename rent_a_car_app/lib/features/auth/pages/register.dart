import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/otp_verification_screen.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _pacoteController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _accountType = 'Cliente';
  final Map<String, String> _accountTypeMap = {
    'Cliente': 'client',
    'Proprietário': 'owner',
  };
  final List<String> _accountTypes = ['Cliente', 'Proprietário'];

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final api = ApiService();
      final typeAccount = _accountTypeMap[_accountType]!;
      final endpoint = typeAccount == 'owner' ? '/owner/signup' : '/client/signup';
      final payload = typeAccount == 'owner'
          ? {
              'name': _nomeController.text.trim(),
              'lastName': _apelidoController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
              'passwordConfirm': _confirmPasswordController.text.trim(),
              'telephone': _telefoneController.text.trim(),
              'address': _enderecoController.text.trim(),
              'package': _pacoteController.text.trim(),
              'typeAccount': typeAccount,
            }
          : {
              'name': _nomeController.text.trim(),
              'lastName': _apelidoController.text.trim(),
              'email': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
              'passwordConfirm': _confirmPasswordController.text.trim(),
              'telephone': _telefoneController.text.trim(),
              'typeAccount': typeAccount,
            };
      final response = await api.post(endpoint, payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: _emailController.text.trim(),
              typeAccount: typeAccount,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Erro ao cadastrar. Tente novamente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao cadastrar: ' + e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.car_rental, color: Colors.white, size: 20),
        ),
        title: Text(
          'Koila',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),

              // Título
              Center(
                child: Text(
                  'Registro',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Dropdown Tipo de Conta
              DropdownButtonFormField<String>(
                value: _accountType,
                items: _accountTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _accountType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de Conta',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 24),

              // Campo Nome
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          hintText: 'Nome',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),

                  // Campo Apelido
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _apelidoController,
                        decoration: InputDecoration(
                          hintText: 'Apelido',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Campo Email
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'E-mail',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Campo Telefone
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Telefone',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o telefone';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 16),

              // Campo Endereço
              if (_accountType == 'Proprietário') ...[
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextFormField(
                    controller: _enderecoController,
                    decoration: InputDecoration(
                      hintText: 'Endereço',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (_accountType == 'Proprietário' && (value == null || value.trim().isEmpty)) {
                        return 'Informe o endereço';
                      }
                      return null;
                    },
                  ),
                ),
              ],

              SizedBox(height: 16),

              // Campo Senha
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Campo Confirmar Senha
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Confirmar Senha',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[500],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 32),

              // Botão Cadastrar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      await _register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D3E3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Cadastrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (_isLoading) ...[
                SizedBox(height: 16),
                Center(child: CircularProgressIndicator()),
              ],

              if (_errorMessage != null) ...[
                SizedBox(height: 16),
                Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red))),
              ],

              SizedBox(height: 16),

              // Botão Login
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Navegar para tela de login
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Texto "Ou"
              Center(
                child: Text(
                  'Ou',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),

              SizedBox(height: 24),

              // Botão Google
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Lógica Google
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  icon: Text(
                    'G',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  label: Text(
                    'Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Texto "Já existe a conta?"
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Já existe a conta? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Entrar.',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Indicador na parte inferior
              Center(
                child: Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _pacoteController.dispose();
    super.dispose();
  }
}
