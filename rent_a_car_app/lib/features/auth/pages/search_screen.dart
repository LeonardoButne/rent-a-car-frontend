import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/car_service.dart';
import 'package:rent_a_car_app/models/brand.dart';
import 'package:rent_a_car_app/widgets/car_card.dart';
import '../../../core/models/car_model.dart';
import 'filter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controladores e estado
  final TextEditingController _searchController = TextEditingController();
  List<ApiCar> searchResults = [];
  List<ApiCar> recommendedCars = [];
  List<ApiCar> popularCars = [];
  List<ApiCar> allCars = [];
  List<Brand> brands = [];
  String? selectedFilter;
  bool isSearching = false;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  Set<String> favoriteCars = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carrega dados iniciais da tela de busca
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      // Carregar todos os carros da API
      final cars = await CarService.getAllCars();
      
      if (mounted) {
        setState(() {
          allCars = cars;
          recommendedCars = _getRecommendedCars(cars);
          popularCars = _getPopularCars(cars);
          brands = _getBrands(cars);
          isLoading = false;
          hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  /// Obtém carros recomendados (featured)
  List<ApiCar> _getRecommendedCars(List<ApiCar> cars) {
    return cars.where((car) => car.featured).take(6).toList();
  }

  /// Obtém carros populares (mais recentes)
  List<ApiCar> _getPopularCars(List<ApiCar> cars) {
    var sortedCars = List<ApiCar>.from(cars);
    sortedCars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedCars.take(8).toList();
  }

  /// Obtém marcas únicas dos carros
  List<Brand> _getBrands(List<ApiCar> cars) {
    final uniqueBrands = <String, Brand>{};

    for (var car in cars) {
      if (!uniqueBrands.containsKey(car.marca)) {
        uniqueBrands[car.marca] = Brand(
          id: car.marca.toLowerCase().replaceAll(' ', '_'),
          name: car.marca,
          slug: car.marca.toLowerCase().replaceAll(' ', '_'),
          logoUrl: 'assets/brands/${car.marca.toLowerCase().replaceAll(' ', '_')}_logo.png',
        );
      }
    }

    final brandsList = uniqueBrands.values.toList();
    brandsList.sort((a, b) => a.name.compareTo(b.name));
    return brandsList;
  }

  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FiltersScreen()),
    );

    if (result != null) {
      // Aplicar filtros recebidos
      _applyFilters(result);
    }
  }

  void _applyFilters(Map<String, dynamic> filters) {
    // Implementar lógica de filtros
    print('Filtros aplicados: $filters');

    // como usar os filtros:
    setState(() {
      // Filtrar carros baseado nos critérios selecionados
      if (filters['carType'] != 'All Cars') {
        // Filtrar por tipo de carro
      }
      // Aplicar outros filtros...
    });
  }

  /// Manipula mudanças no campo de busca
  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults = _searchCars(query);
    });
  }

  /// Busca carros por termo
  List<ApiCar> _searchCars(String query) {
    final term = query.toLowerCase();
    return allCars.where((car) =>
      car.marca.toLowerCase().contains(term) ||
      car.modelo.toLowerCase().contains(term) ||
      car.cor.toLowerCase().contains(term) ||
      car.localizacao.toLowerCase().contains(term) ||
      car.descricao.toLowerCase().contains(term) ||
      car.classe.toLowerCase().contains(term) ||
      car.categorias.toLowerCase().contains(term) ||
      car.placa.toLowerCase().contains(term)
    ).toList();
  }

  /// filtro por marca
  void _applyBrandFilter(String brandSlug) {
    setState(() {
      if (selectedFilter == brandSlug) {
        selectedFilter = null;
        recommendedCars = _getRecommendedCars(allCars);
        popularCars = _getPopularCars(allCars);
      } else {
        selectedFilter = brandSlug;
        final brandName = brandSlug.replaceAll('_', ' ');
        final filteredCars = allCars.where((car) => 
          car.marca.toLowerCase() == brandName.toLowerCase()
        ).toList();
        recommendedCars = filteredCars.take(2).toList();
        popularCars = filteredCars.skip(2).toList();
      }
    });
  }

  /// Toggle favorito
  void _toggleFavorite(String carId) {
    setState(() {
      if (favoriteCars.contains(carId)) {
        favoriteCars.remove(carId);
      } else {
        favoriteCars.add(carId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (!isSearching && !isLoading) _buildFilters(),
            Expanded(
              child: isLoading 
                  ? _buildLoadingState()
                  : hasError
                      ? _buildErrorState()
                      : isSearching 
                          ? _buildSearchResults() 
                          : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Carregando carros...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(
            errorMessage ?? 'Ocorreu um erro ao carregar os carros.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Procure',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (!isLoading)
            GestureDetector(
              onTap: _loadInitialData,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.refresh, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  ///barra de busca ativa
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _openFilters,
              child: Icon(Icons.tune, color: Colors.grey[400]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Procure o seu carro do sonho...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                autofocus: true,
              ),
            ),
            Icon(Icons.tune, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// filtros por marca
  Widget _buildFilters() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const SizedBox(width: 20),
          _buildFilterChip('Todas', selectedFilter == null),
          ...brands.map((brand) => _buildBrandFilterChip(brand)),
        ],
      ),
    );
  }

  /// chip de filtro "Todas"
  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = null;
          _loadInitialData();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Constrói chip de filtro por marca
  Widget _buildBrandFilterChip(Brand brand) {
    final isSelected = selectedFilter == brand.slug;

    return GestureDetector(
      onTap: () => _applyBrandFilter(brand.slug),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          brand.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// resultados da busca
  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Carro não foi encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tenta ajustar os seus termos de procura',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final car = searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: CarCard(
            car: car,
            isFavorite: favoriteCars.contains(car.id),
            onFavorite: () => _toggleFavorite(car.id),
            onTap: () => _showCarDetails(car),
          ),
        );
      },
    );
  }

  /// conteúdo principal
  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRecommendedSection(),
          const SizedBox(height: 30),
          _buildPopularCarsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Constrói seção de carros recomendados
  Widget _buildRecommendedSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedFilter != null
                    ? '${selectedFilter!.substring(0, 1).toUpperCase()}${selectedFilter!.substring(1)} Carros'
                    : 'Recomendado para si',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'todos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: recommendedCars.length,
            itemBuilder: (context, index) {
              final car = recommendedCars[index];
              return CarCard(
                car: car,
                isFavorite: favoriteCars.contains(car.id),
                onFavorite: () => _toggleFavorite(car.id),
                onTap: () => _showCarDetails(car),
              );
            },
          ),
        ),
      ],
    );
  }

  /// seção de carros populares
  Widget _buildPopularCarsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Carros Populares',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Todos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: popularCars.length,
            itemBuilder: (context, index) {
              final car = popularCars[index];
              return CarCard(
                car: car,
                isFavorite: favoriteCars.contains(car.id),
                onFavorite: () => _toggleFavorite(car.id),
                onTap: () => _showCarDetails(car),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Exibe detalhes do carro (placeholder)
  void _showCarDetails(ApiCar car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(car.marca),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca: ${car.marca}'),
            Text('Preço: ${car.precoPorDia}/dia'),
            Text('Localização: ${car.localizacao}'),
            Text('Cadeiras: ${car.lugares}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar lógica de reserva
              _showBookingConfirmation(car);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reserve já'),
          ),
        ],
      ),
    );
  }

  /// Exibe confirmação de reserva
  void _showBookingConfirmation(ApiCar car) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${car.marca} Aluguer iniciado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
