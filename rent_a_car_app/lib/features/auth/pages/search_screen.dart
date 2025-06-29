import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/car_service.dart';
import 'package:rent_a_car_app/models/brand.dart';
import 'package:rent_a_car_app/models/car.dart';
import 'package:rent_a_car_app/widgets/car_card.dart';
import 'filter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controladores e estado
  final TextEditingController _searchController = TextEditingController();
  List<Car> searchResults = [];
  List<Car> recommendedCars = [];
  List<Car> popularCars = [];
  List<Brand> brands = [];
  String? selectedFilter;
  bool isSearching = false;
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
  void _loadInitialData() {
    setState(() {
      recommendedCars = CarService.getRecommendedCars();
      popularCars = CarService.getPopularCars();
      brands = CarService.getBrands();
    });
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
      searchResults = CarService.searchCars(query);
    });
  }

  /// filtro por marca
  void _applyBrandFilter(String brandSlug) {
    setState(() {
      if (selectedFilter == brandSlug) {
        selectedFilter = null;
        recommendedCars = CarService.getRecommendedCars();
        popularCars = CarService.getPopularCars();
      } else {
        selectedFilter = brandSlug;
        final filteredCars = CarService.getCarsByBrand(brandSlug);
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
            if (!isSearching) _buildFilters(),
            Expanded(
              child: isSearching ? _buildSearchResults() : _buildMainContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          const Icon(Icons.more_horiz),
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
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  brand.logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 24);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              brand.name,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
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

  /// bottom navigation bar
  Widget _buildBottomNavigationBar() {
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
          _buildNavItem(Icons.search, true),
          _buildNavItem(Icons.mail_outline, false),
          _buildNavItem(Icons.notifications_outlined, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  /// item do navigation bar
  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        size: 24,
      ),
    );
  }

  /// Exibe detalhes do carro (placeholder)
  void _showCarDetails(Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(car.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca: ${car.brand}'),
            Text('Preço: ${car.pricePerDay}/dia'),
            Text('Localização: ${car.location}'),
            Text('Avaliação: ${car.rating}'),
            Text('Cadeiras: ${car.seats}'),
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
  void _showBookingConfirmation(Car car) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${car.name} Aluguer iniciado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
