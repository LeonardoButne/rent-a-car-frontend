import 'package:flutter/material.dart';
import 'package:rent_a_car_app/models/dealer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela simples de detalhes do dealer
/// Mostra foto, nome, localização e opções de contato
class DealerDetailsScreen extends StatelessWidget {
  final Dealer dealer;

  const DealerDetailsScreen({super.key, required this.dealer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent()),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Constrói header da tela
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
          ),
          const Expanded(
            child: Text(
              'Detalhes do proprietário',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 42), // Para balancear o layout
        ],
      ),
    );
  }

  /// Constrói conteúdo principal
  Widget _buildContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 24),
            _buildDealerName(),
            const SizedBox(height: 16),
            _buildLocation(),
            const SizedBox(height: 16),
            _buildPhone(),
          ],
        ),
      ),
    );
  }

  /// Constrói foto do perfil
  Widget _buildProfileImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.orange,
        child: dealer.profileImage != null
            ? ClipOval(
                child: Image.network(
                  dealer.profileImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    );
                  },
                ),
              )
            : const Icon(Icons.person, size: 50, color: Colors.white),
      ),
    );
  }

  /// Constrói nome do dealer
  Widget _buildDealerName() {
    return Text(
      dealer.name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Constrói localização
  Widget _buildLocation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          dealer.location,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }

  /// Constrói telefone
  Widget _buildPhone() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.phone, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          dealer.phone,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Constrói botões de ação
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _buildCallButton(context)),
          const SizedBox(width: 16),
          Expanded(child: _buildWhatsAppButton(context)),
        ],
      ),
    );
  }

  /// Constrói botão de ligação
  Widget _buildCallButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _makePhoneCall(context),
      icon: const Icon(Icons.phone, size: 20),
      label: const Text(
        'Ligar',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2,
      ),
    );
  }

  /// Constrói botão do WhatsApp
  Widget _buildWhatsAppButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openWhatsApp(context),
      icon: const Icon(Icons.chat, size: 20),
      label: const Text(
        'WhatsApp',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366), // Cor do WhatsApp
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2,
      ),
    );
  }

  /// Faz ligação telefônica
  Future<void> _makePhoneCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: dealer.phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorMessage(context, 'Não foi possível fazer a ligação');
      }
    } catch (e) {
      _showErrorMessage(context, 'Erro ao tentar ligar');
    }
  }

  /// Abre WhatsApp
  Future<void> _openWhatsApp(BuildContext context) async {
    // Remove caracteres especiais do número
    final cleanPhone = dealer.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent(
      'Olá! Vi seu carro no app Koila e tenho interesse.',
    );
    final whatsappUri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorMessage(context, 'WhatsApp não encontrado');
      }
    } catch (e) {
      _showErrorMessage(context, 'Erro ao abrir WhatsApp');
    }
  }

  /// Mostra mensagem de erro
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
