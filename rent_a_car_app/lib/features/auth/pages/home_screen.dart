import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/car_service.dart';
import 'package:rent_a_car_app/features/auth/pages/car_details_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/messages/chats_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/notifications/notification_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/profile/profile_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/search_screen.dart';
import 'package:rent_a_car_app/models/brand.dart';
import 'package:rent_a_car_app/models/car.dart';
import 'package:rent_a_car_app/widgets/brand_selector.dart';
import 'package:rent_a_car_app/widgets/car_card.dart';
import 'package:rent_a_car_app/widgets/section_header.dart';

/// Exibe marcas, carros em destaque, próximos e populares
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado da tela
  String? selectedBrand;
  List<Car> bestCars = [];
  List<Car> nearbyCars = [];
  List<Brand> brands = [];
  Set<String> favoriteCars = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carrega dados iniciais da tela
  void _loadData() {
    setState(() {
      brands = CarService.getBrands();
      bestCars = CarService.getBestCars();
      nearbyCars = CarService.getNearbyCars();
    });
  }

  /// Manipula seleção de marca
  void _onBrandSelected(String brandSlug) {
    setState(() {
      selectedBrand = selectedBrand == brandSlug ? null : brandSlug;

      if (selectedBrand != null) {
        // Filtra carros pela marca selecionada
        bestCars = CarService.getCarsByBrand(selectedBrand!);
      } else {
        // Volta a exibir todos os carros
        bestCars = CarService.getBestCars();
      }
    });
  }

  /// Adiciona/remove carro dos favoritos
  void _toggleFavorite(String carId) {
    setState(() {
      if (favoriteCars.contains(carId)) {
        favoriteCars.remove(carId);
      } else {
        favoriteCars.add(carId);
      }
    });
  }

  /// Navega para tela de busca
  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildBrandsSection(),
                    const SizedBox(height: 30),
                    _buildBestCarsSection(),
                    const SizedBox(height: 30),
                    _buildNearbyCarsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Koila',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Stack(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// barra de pesquisa
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _navigateToSearch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(
                'Procure pelo seu carro...',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const Spacer(),
              Icon(Icons.tune, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// seção de marcas
  Widget _buildBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Marcas'),
        const SizedBox(height: 16),
        BrandSelector(
          brands: brands,
          selectedBrand: selectedBrand,
          onBrandSelected: _onBrandSelected,
        ),
      ],
    );
  }

  /// seção de melhores carros
  Widget _buildBestCarsSection() {
    return Column(
      children: [
        SectionHeader(
          title: selectedBrand != null
              ? '${selectedBrand!.substring(0, 1).toUpperCase()}${selectedBrand!.substring(1)} Carros'
              : 'Melhores carros',
          onViewAll: () {
            // Implementar navegação para lista completa
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: bestCars.length,
            itemBuilder: (context, index) {
              final car = bestCars[index];
              return CarCard(
                car: car,
                isFavorite: favoriteCars.contains(car.id),
                onFavorite: () => _toggleFavorite(car.id),
                onTap: () {
                  // Implementar navegação para detalhes do carro
                  _showCarDetails(car);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  ///  seção de carros próximos
  Widget _buildNearbyCarsSection() {
    return Column(
      children: [
        SectionHeader(
          title: 'Carros Próximos',
          onViewAll: () {
            // Implementar navegação para lista completa
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: nearbyCars.length,
            itemBuilder: (context, index) {
              final car = nearbyCars[index];
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
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, true),
          _buildNavItem(Icons.search, false),

          //push para a tela de chats
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.email,
                color: Colors.white, // Destacado
                size: 24,
              ),
            ),
          ),

          //push para tela de notificações
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.notifications,
                color: Colors.white, // Destacado
                size: 24,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.person,
                color: Colors.white, // Destacado
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói item do navigation bar
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
    );
  }
}
