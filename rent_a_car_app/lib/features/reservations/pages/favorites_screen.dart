import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rent_a_car_app/core/utils/base_url.dart';

// ============================================================================
// MODELO DE DADOS
// ============================================================================

class FavoriteCar {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String year;
  final double pricePerDay;
  final String imageUrl;
  final String location;
  final double rating;
  final int reviewCount;
  final String fuelType;
  final String transmission;
  final bool isAvailable;
  final DateTime addedToFavorites;

  FavoriteCar({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.fuelType,
    required this.transmission,
    required this.isAvailable,
    required this.addedToFavorites,
  });

  factory FavoriteCar.fromJson(Map<String, dynamic> json) {
    return FavoriteCar(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      fuelType: json['fuelType'] ?? '',
      transmission: json['transmission'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      addedToFavorites: json['addedToFavorites'] != null
          ? DateTime.parse(json['addedToFavorites'])
          : DateTime.now(),
    );
  }
}

// ============================================================================
// WIDGETS ORGANIZADOS - COMPONENTES REUTILIZÁVEIS
// ============================================================================

/// Header moderno da tela de favoritos
class FavoritesHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSearchPressed;
  final int favoritesCount;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  const FavoritesHeader({
    super.key,
    required this.onBackPressed,
    required this.onSearchPressed,
    required this.favoritesCount,
    required this.isSelectionMode,
    required this.selectedCount,
    this.onDeleteSelected,
    this.onSelectAll,
    this.onDeselectAll,
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
      child: Column(
        children: [
          Row(
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
                  child: Icon(
                    isSelectionMode
                        ? Icons.close_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelectionMode
                          ? '$selectedCount Selecionados'
                          : 'Favoritos',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (!isSelectionMode)
                      Text(
                        '$favoritesCount carros salvos',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelectionMode) ...[
                if (onDeleteSelected != null)
                  GestureDetector(
                    onTap: onDeleteSelected,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ] else ...[
                GestureDetector(
                  onTap: onSearchPressed,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isSelectionMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onSelectAll != null)
                  _buildActionButton(
                    'Selecionar todos',
                    Icons.select_all_rounded,
                    onSelectAll!,
                  ),
                const Spacer(),
                if (onDeselectAll != null)
                  _buildActionButton(
                    'Desmarcar todos',
                    Icons.deselect_rounded,
                    onDeselectAll!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filtros e ordenação
class FavoritesFilters extends StatelessWidget {
  final List<String> sortOptions;
  final String selectedSort;
  final Function(String) onSortChanged;

  const FavoritesFilters({
    super.key,
    required this.sortOptions,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sortOptions.length,
        itemBuilder: (context, index) {
          final option = sortOptions[index];
          final isSelected = selectedSort == option;

          return GestureDetector(
            onTap: () => onSortChanged(option),
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
                option,
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

/// Card de carro favorito
class FavoriteCarCard extends StatelessWidget {
  final FavoriteCar car;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteToggle;

  const FavoriteCarCard({
    super.key,
    required this.car,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [_buildCarImage(), _buildCarInfo()]),
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // Imagem do carro
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: car.imageUrl.isNotEmpty
                ? Image.network(
                    car.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),

          // Overlay de status
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: car.isAvailable ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                car.isAvailable ? 'Disponível' : 'Indisponível',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Botão de favorito
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 18),
              ),
            ),
          ),

          // Checkbox de seleção
          if (isSelectionMode)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.black : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey[200],
      child: const Icon(
        Icons.directions_car_rounded,
        size: 60,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildCarInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  car.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${car.pricePerDay.toStringAsFixed(0)} MZN',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${car.brand} ${car.model} • ${car.year}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  car.location,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      car.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeatureChip(car.fuelType, Icons.local_gas_station_rounded),
              const SizedBox(width: 8),
              _buildFeatureChip(car.transmission, Icons.settings_rounded),
              const Spacer(),
              Text(
                '/dia',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estados visuais
class FavoritesLoadingState extends StatelessWidget {
  const FavoritesLoadingState({super.key});

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
            'Carregando favoritos...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const FavoritesEmptyState({super.key, required this.onExplorePressed});

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
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum favorito ainda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore nossos carros e salve\nseus favoritos aqui',
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

// ============================================================================
// SERVIÇOS
// ============================================================================

class FavoritesService {
  /// Busca carros favoritos
  static Future<List<FavoriteCar>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => FavoriteCar.fromJson(e)).toList();
      } else {
        throw Exception('Erro ao buscar favoritos');
      }
    } catch (e) {
      throw Exception('Erro ao buscar favoritos: $e');
    }
  }

  /// Remove carro dos favoritos
  static Future<void> removeFavorite(String carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$carId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao remover favorito');
      }
    } catch (e) {
      throw Exception('Erro ao remover favorito: $e');
    }
  }

  /// Remove múltiplos favoritos
  static Future<void> removeMultipleFavorites(List<String> carIds) async {
    try {
      for (final id in carIds) {
        await removeFavorite(id);
      }
    } catch (e) {
      throw Exception('Erro ao remover favoritos: $e');
    }
  }
}

// ============================================================================
// HELPERS
// ============================================================================

class FavoritesHelpers {
  /// Mostra diálogo de confirmação
  static Future<bool> showRemoveConfirmation(
    BuildContext context,
    int count,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover dos Favoritos'),
        content: Text(
          'Tem certeza que deseja remover ${count > 1 ? '$count carros' : 'este carro'} dos favoritos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Mostra feedback
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

  /// Ordena lista de favoritos
  static List<FavoriteCar> sortFavorites(
    List<FavoriteCar> favorites,
    String sortBy,
  ) {
    final sortedList = List<FavoriteCar>.from(favorites);

    switch (sortBy) {
      case 'Recentes':
        sortedList.sort(
          (a, b) => b.addedToFavorites.compareTo(a.addedToFavorites),
        );
        break;
      case 'Antigos':
        sortedList.sort(
          (a, b) => a.addedToFavorites.compareTo(b.addedToFavorites),
        );
        break;
      case 'Menor Preço':
        sortedList.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'Maior Preço':
        sortedList.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'Melhor Avaliação':
        sortedList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }

    return sortedList;
  }
}

// ============================================================================
// TELA PRINCIPAL
// ============================================================================

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  List<FavoriteCar> _favorites = [];
  List<FavoriteCar> _selectedFavorites = [];
  bool _isSelectionMode = false;
  bool _isLoading = true;
  String _selectedSort = 'Recentes';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _sortOptions = [
    'Recentes',
    'Antigos',
    'Menor Preço',
    'Maior Preço',
    'Melhor Avaliação',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFavorites();
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

  void _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final favorites = await FavoritesService.getFavorites();
      setState(() {
        _favorites = FavoritesHelpers.sortFavorites(favorites, _selectedSort);
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      FavoritesHelpers.showFeedback(
        context,
        'Erro ao carregar favoritos. Tente novamente.',
        isError: true,
      );
    }
  }

  void _toggleSelection(FavoriteCar car) {
    setState(() {
      if (_selectedFavorites.contains(car)) {
        _selectedFavorites.remove(car);
      } else {
        _selectedFavorites.add(car);
      }

      if (_selectedFavorites.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _onCarTap(FavoriteCar car) {
    if (_isSelectionMode) {
      _toggleSelection(car);
    } else {
      // Navegar para detalhes do carro
      Navigator.pushNamed(context, '/car-details', arguments: car.id);
    }
  }

  void _onCarLongPress(FavoriteCar car) {
    setState(() {
      _isSelectionMode = true;
      if (!_selectedFavorites.contains(car)) {
        _selectedFavorites.add(car);
      }
    });
  }

  void _onBackPressed() {
    if (_isSelectionMode) {
      setState(() {
        _isSelectionMode = false;
        _selectedFavorites.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _onSelectAll() {
    setState(() {
      _selectedFavorites = List.from(_favorites);
    });
  }

  void _onDeselectAll() {
    setState(() {
      _selectedFavorites.clear();
    });
  }

  Future<void> _onRemoveFavorite(FavoriteCar car) async {
    try {
      await FavoritesService.removeFavorite(car.id);
      setState(() {
        _favorites.remove(car);
        _selectedFavorites.remove(car);
      });
      FavoritesHelpers.showFeedback(context, 'Removido dos favoritos');
    } catch (e) {
      FavoritesHelpers.showFeedback(
        context,
        'Erro ao remover favorito',
        isError: true,
      );
    }
  }

  Future<void> _onDeleteSelected() async {
    if (_selectedFavorites.isEmpty) return;

    final confirmed = await FavoritesHelpers.showRemoveConfirmation(
      context,
      _selectedFavorites.length,
    );

    if (!confirmed) return;

    try {
      final carIds = _selectedFavorites.map((car) => car.id).toList();
      await FavoritesService.removeMultipleFavorites(carIds);

      setState(() {
        for (final car in _selectedFavorites) {
          _favorites.remove(car);
        }
        _selectedFavorites.clear();
        _isSelectionMode = false;
      });

      FavoritesHelpers.showFeedback(context, 'Favoritos removidos com sucesso');
    } catch (e) {
      FavoritesHelpers.showFeedback(
        context,
        'Erro ao remover favoritos',
        isError: true,
      );
    }
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _selectedSort = sortBy;
      _favorites = FavoritesHelpers.sortFavorites(_favorites, sortBy);
    });
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
              FavoritesHeader(
                onBackPressed: _onBackPressed,
                onSearchPressed: () {
                  // Implementar busca se necessário
                  FavoritesHelpers.showFeedback(
                    context,
                    'Busca em desenvolvimento',
                  );
                },
                favoritesCount: _favorites.length,
                isSelectionMode: _isSelectionMode,
                selectedCount: _selectedFavorites.length,
                onDeleteSelected: _selectedFavorites.isNotEmpty
                    ? _onDeleteSelected
                    : null,
                onSelectAll: _isSelectionMode ? _onSelectAll : null,
                onDeselectAll: _isSelectionMode && _selectedFavorites.isNotEmpty
                    ? _onDeselectAll
                    : null,
              ),
              if (_isLoading)
                const Expanded(child: FavoritesLoadingState())
              else if (_favorites.isEmpty)
                Expanded(
                  child: FavoritesEmptyState(
                    onExplorePressed: () => Navigator.pop(context),
                  ),
                )
              else ...[
                FavoritesFilters(
                  sortOptions: _sortOptions,
                  selectedSort: _selectedSort,
                  onSortChanged: _onSortChanged,
                ),
                Expanded(child: _buildFavoritesList()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final car = _favorites[index];
        return FavoriteCarCard(
          car: car,
          isSelected: _selectedFavorites.contains(car),
          isSelectionMode: _isSelectionMode,
          onTap: () => _onCarTap(car),
          onLongPress: () => _onCarLongPress(car),
          onFavoriteToggle: () => _onRemoveFavorite(car),
        );
      },
    );
  }
}
