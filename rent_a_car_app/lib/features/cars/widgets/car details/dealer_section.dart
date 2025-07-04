import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/car_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DealerSection extends StatelessWidget {
  final VoidCallback onContact;
  final CarOwner owner;

  const DealerSection({
    super.key,
    required this.onContact,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proprietário',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showOwnerDetailsModal(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange,
                    child: Text(
                      owner.name.isNotEmpty ? owner.name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${owner.name} ${owner.lastName ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        if (owner.address != null && owner.address!.isNotEmpty)
                          Text(
                            owner.address!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOwnerDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _OwnerDetailsModal(owner: owner),
    );
  }
}

// ===========================
// 📁 Widget Modal dos Detalhes do Proprietário
// ===========================

class _OwnerDetailsModal extends StatelessWidget {
  final CarOwner owner;

  const _OwnerDetailsModal({required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildOwnerInfo(),
            _buildStatsSection(),
            _buildContactOptions(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            'Contatar Proprietário',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Verificado',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                owner.name.isNotEmpty ? owner.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${owner.name} ${owner.lastName ?? ''}'.trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                if (owner.address != null && owner.address!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          owner.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (owner.telephone != null)
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        owner.telephone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('15', 'Carros\nDisponíveis')),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(child: _buildStatItem('4.9', 'Avaliação\nMédia')),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(child: _buildStatItem('284', 'Aluguéis\nRealizados')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.2),
        ),
      ],
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (owner.telephone != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildContactButton(
                    context: context,
                    icon: Icons.phone,
                    title: 'Ligar',
                    color: Colors.green,
                    onTap: () => _makePhoneCall(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactButton(
                    context: context,
                    icon: Icons.chat,
                    title: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _openWhatsApp(context),
                  ),
                ),
              ],
            ),
          ],
          if (owner.email != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildContactButton(
                context: context,
                icon: Icons.email,
                title: 'Enviar Email',
                color: Colors.blue,
                onTap: () => _sendEmail(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    if (owner.telephone == null) return;

    final Uri phoneUri = Uri(scheme: 'tel', path: owner.telephone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        Navigator.pop(context);
      } else {
        _showErrorMessage(context, 'Não foi possível fazer a ligação');
      }
    } catch (e) {
      _showErrorMessage(context, 'Erro ao tentar ligar');
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    if (owner.telephone == null) return;

    final cleanPhone = owner.telephone!.replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent(
      'Olá! Vi seu carro no app Koila e tenho interesse.',
    );
    final whatsappUri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        _showErrorMessage(context, 'WhatsApp não encontrado');
      }
    } catch (e) {
      _showErrorMessage(context, 'Erro ao abrir WhatsApp');
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    if (owner.email == null) return;

    final emailUri = Uri(
      scheme: 'mailto',
      path: owner.email,
      query:
          'subject=${Uri.encodeComponent('Interesse no veículo')}&body=${Uri.encodeComponent('Olá, vi seu carro no app Koila e gostaria de mais informações.')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Navigator.pop(context);
      } else {
        _showErrorMessage(context, 'Não foi possível abrir o email');
      }
    } catch (e) {
      _showErrorMessage(context, 'Erro ao tentar enviar email');
    }
  }

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
