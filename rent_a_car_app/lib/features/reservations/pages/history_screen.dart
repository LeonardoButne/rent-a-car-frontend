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
import 'package:rent_a_car_app/core/utils/base_url.dart';

// ============================================================================
// WIDGETS ORGANIZADOS - COMPONENTES REUTILIZÁVEIS
// ============================================================================

/// Header moderno da tela de histórico
class HistoryHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSortPressed;

  const HistoryHeader({
    super.key,
    required this.onBackPressed,
    required this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Histórico',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSortPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sort_rounded,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção de estatísticas melhorada
class HistoryStatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const HistoryStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '${stats['totalCars'] ?? 0}',
              'Carros alugados',
              Icons.directions_car_rounded,
              Colors.black,
            ),
          ),
          Container(width: 1, height: 50, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: _buildStatItem(
              '${stats['totalSpent']?.toStringAsFixed(0) ?? '0'} MZN',
              'Valor total',
              Icons.payments_rounded,
              const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Filtros horizontais modernos
class HistoryFilters extends StatelessWidget {
  final List<String> filterOptions;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const HistoryFilters({
    super.key,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Estados visuais melhorados
class HistoryLoadingState extends StatelessWidget {
  const HistoryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Carregando histórico...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class HistoryEmptyState extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const HistoryEmptyState({super.key, required this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3).withOpacity(0.1),
                  const Color(0xFF2196F3).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum aluguel ainda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seu histórico de aluguéis\naparecerá aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onExplorePressed,
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Explorar Carros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryEmptyFilterState extends StatelessWidget {
  final String filterName;

  const HistoryEmptyFilterState({super.key, required this.filterName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.filter_list_off_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluguel $filterName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente outro filtro',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

/// Bottom Navigation melhorado
class HistoryBottomNavigation extends StatelessWidget {
  final int unreadCount;

  const HistoryBottomNavigation({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Remove o bottom navigation
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? Colors.white : const Color(0xFF64748B),
        size: 24,
      ),
    );
  }

  Widget _buildNotificationNavItem(int unreadCount) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
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
}

// ============================================================================
// HELPERS E UTILITÁRIOS
// ============================================================================

class HistoryHelpers {
  /// Mostra bottom sheet de opções de ordenação
  static void showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ordenar por',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),
            _buildSortOption(context, 'Mais recente', Icons.schedule_rounded),
            _buildSortOption(context, 'Mais antigo', Icons.history_rounded),
            _buildSortOption(context, 'Maior valor', Icons.trending_up_rounded),
            _buildSortOption(
              context,
              'Menor valor',
              Icons.trending_down_rounded,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSortOption(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF475569)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ordenado por: $title'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Mostra mensagem de feedback
  static void showFeedback(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ============================================================================
// SERVIÇOS
// ============================================================================

class HistoryNotificationService {
  /// Busca contagem de notificações não lidas
  static Future<int> fetchUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = _getUserIdFromToken(token);

      final response = await http.get(
        Uri.parse('$baseUrl/notification/notifications?userId=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final notifications = data
            .map((e) => NotificationItem.fromJson(e))
            .toList();
        return notifications.where((n) => !n.isRead).length;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final Map<String, dynamic> jsonPayload = json.decode(payload);
      return jsonPayload['sub'];
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// TELA PRINCIPAL
// ============================================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  List<RentalHistory> _history = [];
  Map<String, dynamic> _stats = {};
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  String _typeAccount = '';
  String _userId = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _filterOptions = [
    'Todos',
    'Concluídos',
    'Cancelados',
    'Rejeitados',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserType().then((_) => _loadData());
  }

  @override
  void dispose() {
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

  void _loadData() async {
    setState(() => _isLoading = true);

    try {
      final history = await HistoryService.getHistory();
      List<RentalHistory> filteredHistory = history;

      if (_typeAccount == 'owner' && _userId.isNotEmpty) {
        filteredHistory = history.where((h) => h.ownerId == _userId).toList();
      }

      // Corrigir: considerar apenas reservas finalizadas, canceladas ou rejeitadas para as estatísticas
      final statsHistory = filteredHistory.where((h) =>
        h.status == RentalStatus.completed ||
        h.status == RentalStatus.cancelled ||
        h.status == RentalStatus.rejected
      ).toList();

      final totalCars = statsHistory.length;
      final totalSpent = statsHistory.fold<double>(
        0,
        (sum, h) => sum + h.totalValue,
      );

      setState(() {
        _history = filteredHistory;
        _stats = {'totalCars': totalCars, 'totalSpent': totalSpent};
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      HistoryHelpers.showFeedback(
        context,
        'Erro ao carregar histórico. Tente novamente.',
        isError: true,
      );
    }
  }

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
        // Só mostra concluídos, cancelados e rejeitados no histórico
        return _history.where((h) =>
          h.status == RentalStatus.completed ||
          h.status == RentalStatus.cancelled ||
          h.status == RentalStatus.rejected
        ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              HistoryHeader(
                onBackPressed: () => Navigator.pop(context),
                onSortPressed: () => HistoryHelpers.showSortOptions(context),
              ),
              if (_isLoading)
                const Expanded(child: HistoryLoadingState())
              else if (_history.isEmpty)
                Expanded(
                  child: HistoryEmptyState(
                    onExplorePressed: () => Navigator.pop(context),
                  ),
                )
              else ...[
                HistoryStatsSection(stats: _stats),
                HistoryFilters(
                  filterOptions: _filterOptions,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
                Expanded(child: _buildHistoryList()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final filteredHistory = _filteredHistory;

    if (filteredHistory.isEmpty) {
      return HistoryEmptyFilterState(filterName: _selectedFilter.toLowerCase());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: HistoryCard(
            rental: filteredHistory[index],
            isOwner: _typeAccount == 'owner',
          ),
        );
      },
    );
  }
}
