import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/history_service.dart';
import 'package:rent_a_car_app/models/rental_history.dart';
import 'package:rent_a_car_app/features/reservations/widgets/history/history_card.dart';
import 'package:rent_a_car_app/features/reservations/widgets/history/loading_skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rent_a_car_app/features/notifications/models/notification_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert';
import 'package:rent_a_car_app/core/utils/base_url.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RentalHistory> _history = [];
  Map<String, dynamic> _stats = {};
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  String _typeAccount = '';
  String _userId = '';

  final List<String> _filterOptions = [
    'Todos',
    'Concluídos',
    'Cancelados',
    'Rejeitados',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserType().then((_) => _loadData());
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        _typeAccount = decodedToken['typeAccount'] ?? '';
        _userId = decodedToken['sub'] ?? '';
      });
    }
  }

  /// Carrega dados do histórico da API
  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carrega dados da API real
      final history = await HistoryService.getHistory();
      List<RentalHistory> filteredHistory = history;
      // Só filtrar se _typeAccount for owner e _userId não for vazio
      if (_typeAccount == 'owner' && _userId.isNotEmpty) {
        filteredHistory = history.where((h) => h.ownerId == _userId).toList();
      }
      // Calcular estatísticas localmente
      final totalCars = filteredHistory.length;
      final totalSpent = filteredHistory.fold<double>(0, (sum, h) => sum + h.totalValue);
      setState(() {
        _history = filteredHistory;
        _stats = {
          'totalCars': totalCars,
          'totalSpent': totalSpent,
        };
        _isLoading = false;
      });
    } catch (error) {
      // Tratamento de erro da API
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar histórico. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Filtra histórico baseado na seleção
  List<RentalHistory> get _filteredHistory {
    switch (_selectedFilter) {
      case 'Concluídos':
        return _history
            .where((h) => h.status == RentalStatus.completed)
            .toList();
      case 'Cancelados':
        return _history
            .where((h) => h.status == RentalStatus.cancelled)
            .toList();
      case 'Rejeitados':
        return _history
            .where((h) => h.status == RentalStatus.rejected)
            .toList();
      default:
        return _history;
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
            if (_isLoading)
              const Expanded(child: LoadingSkeleton())
            else if (_history.isEmpty)
              Expanded(child: _buildEmptyState())
            else ...[
              _buildStatsSection(),
              _buildFiltersSection(),
              Expanded(child: _buildHistoryList()),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  ///header da tela
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
              'Histórico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.sort, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// seção de estatísticas
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '${_stats['totalCars']}',
              'Carros alugados',
              Icons.directions_car,
              Colors.blue,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(
            child: _buildStatItem(
              '${_stats['totalSpent']?.toStringAsFixed(0)} MZN',
              'Valor gasto',
              Icons.currency_exchange,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// item individual de estatística
  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// seção de filtros
  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// lista do histórico
  Widget _buildHistoryList() {
    final filteredHistory = _filteredHistory;

    if (filteredHistory.isEmpty) {
      return _buildEmptyFilterState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        return HistoryCard(
          rental: filteredHistory[index],
          isOwner: _typeAccount == 'owner',
          // onTap: () => _showRentalDetails(filteredHistory[index]),
        );
      },
    );
  }

  /// estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum aluguel ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu histórico de aluguéis\naparecerá aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Explorar Carros',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// estado vazio para filtros
  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluguel $_selectedFilter',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente outro filtro',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Constrói bottom navigation
  Widget _buildBottomNavigation() {
    return FutureBuilder<int>(
      future: _fetchUnreadNotificationsCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        return Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, false),
              _buildNavItem(Icons.search, false),
              _buildNavItem(Icons.chat_bubble_outline, false),
              _buildNotificationNavItem(unreadCount),
              _buildNavItem(Icons.person_outline, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 24),
    );
  }

  Widget _buildNotificationNavItem(int unreadCount) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<int> _fetchUnreadNotificationsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = _getUserIdFromToken(token);
    final response = await http.get(
      Uri.parse('$baseUrl/notification/notifications?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
      return notifications.where((n) => !n.isRead).length;
    } else {
      throw Exception('Erro ao buscar notificações');
    }
  }

  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final Map<String, dynamic> jsonPayload = json.decode(payload);
    return jsonPayload['sub'];
  }

  /// Mostra opções de ordenação
  void _showSortOptions() {
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
              'Ordenar por',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Mais recente', Icons.schedule),
            _buildSortOption('Mais antigo', Icons.history),
            _buildSortOption('Maior valor', Icons.trending_up),
            _buildSortOption('Menor valor', Icons.trending_down),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ordenado por: $title')));
      },
    );
  }

  /// Mostra detalhes do aluguel
  // void _showRentalDetails(RentalHistory rental) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => RentalDetailsModal(rental: rental),
  //   );
  // }
}
