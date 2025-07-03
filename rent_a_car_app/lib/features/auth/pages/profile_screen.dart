import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/edit_profile_screen.dart';
import 'package:rent_a_car_app/models/profile_menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rent_a_car_app/features/cars/pages/vehicle_registration_screen.dart';
import 'package:rent_a_car_app/features/owner/pages/owner_reservations_screen.dart';


import 'my_reservations_screen.dart';
import '../../notifications/pages/notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String typeAccount = '';
  final String userAvatar = 'assets/avatars/enu.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final name = decodedToken['name'] ?? '';
      final lastName = decodedToken['lastName'] ?? '';
      setState(() {
        userName = (name + ' ' + lastName).trim();
        userEmail = decodedToken['email'] ?? '';
        typeAccount = decodedToken['typeAccount'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildGeneralSection(),
                    const SizedBox(height: 24),
                    _buildSupportSection(),
                    const SizedBox(height: 40), // Espaço reduzido
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  /// Constrói header da tela
  Widget _buildHeader() {
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
              'Perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
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

  /// Constrói card do perfil do usuário
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 35, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _navigateToEditProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Editar perfil',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói seção Geral
  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'Geral',
      items: [
        ProfileMenuItem(
          icon: Icons.favorite_outline,
          title: 'Carros Favoritos',
          onTap: _navigateToFavorites,
        ),
        ProfileMenuItem(
          icon: Icons.history,
          title: 'Histórico de Aluguéis',
          onTap: _navigateToHistory,
        ),
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notificações',
          onTap: _navigateToNotifications,
        ),
        ProfileMenuItem(
          icon: Icons.bookmark_outline,
          title: 'Minhas Reservas Solicitadas',
          onTap: _navigateToMyReservations,
        ),
        if (typeAccount == 'owner') ...[
          ProfileMenuItem(
            icon: Icons.add_circle_outline,
            title: 'Cadastrar Carro',
            onTap: _navigateToVehicleRegistration,
          ),
          ProfileMenuItem(
            icon: Icons.directions_car_outlined,
            title: 'Meus Carros',
            onTap: _navigateToMyCars,
          ),
          ProfileMenuItem(
            icon: Icons.assignment,
            title: 'Reservas Recebidas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OwnerReservationsScreen(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  /// Constrói seção Suporte
  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Suporte',
      items: [
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          onTap: _navigateToSettings,
        ),
        ProfileMenuItem(
          icon: Icons.language_outlined,
          title: 'Idioma',
          onTap: _navigateToLanguage,
        ),
        ProfileMenuItem(
          icon: Icons.description_outlined,
          title: 'Política de Privacidade',
          onTap: _navigateToPrivacyPolicy,
        ),
        ProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Suporte',
          onTap: _navigateToSupport,
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Sair',
          onTap: _showLogoutDialog,
          showDivider: false, // Último item
        ),
      ],
    );
  }

  /// Constrói seção genérica com título e itens
  Widget _buildSection({
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.map((item) => _buildMenuItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  /// Constrói item individual do menu
  Widget _buildMenuItem(ProfileMenuItem item) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(item.icon, size: 22, color: Colors.grey[600]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
        if (item.showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey[200],
            indent: 58, // Alinhado com o texto
            endIndent: 20,
          ),
      ],
    );
  }

  // ===========================
  // 🎯 MÉTODOS DE NAVEGAÇÃO
  // ===========================

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(currentName: userName, currentEmail: userEmail),
      ),
    );
  }

  void _navigateToFavorites() {
    _showComingSoon('Carros Favoritos');
  }

  void _navigateToHistory() {
    _showComingSoon('Histórico de Aluguéis');
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(),
      ),
    );
  }

  void _navigateToMyReservations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyReservationsScreen(),
      ),
    );
  }

  void _navigateToVehicleRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleRegistrationScreen(),
      ),
    );
  }

  void _navigateToMyCars() {
    _showComingSoon('Meus Carros');
  }

  void _navigateToSettings() {
    _showComingSoon('Configurações');
  }

  void _navigateToLanguage() {
    _showLanguageOptions();
  }

  void _navigateToPrivacyPolicy() {
    _showComingSoon('Política de Privacidade');
  }

  void _navigateToSupport() {
    _showComingSoon('Central de Suporte');
  }

  // ===========================
  // 🎯 MÉTODOS DE AÇÃO
  // ===========================

  /// Mostra opções de idioma
  void _showLanguageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecionar Idioma',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('🇵🇹', 'Português', true),
            _buildLanguageOption('🇺🇸', 'English', false),
            _buildLanguageOption('🇪🇸', 'Español', false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Constrói opção de idioma
  Widget _buildLanguageOption(String flag, String language, bool isSelected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Idioma alterado para $language'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Mostra dialog de logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Executa logout
  void _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout realizado com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
    // Navegar para tela de login (substituir por sua LoginScreen)
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Mostra mensagem "Em breve"
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature brevemente!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}