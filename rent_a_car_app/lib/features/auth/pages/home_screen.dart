import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/car_details_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/messages/chats_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/notifications/notification_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/profile/profile_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/search_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/my_reservations_screen.dart';

import '../../../core/models/car_model.dart';
import '../../../core/services/car_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedBrand;
  List<ApiCar> allCars = [];
  List<ApiCar> displayedCars = [];
  List<ApiCar> nearbyCars = [];
  List<String> availableBrands = [];
  Set<String> favoriteCars = {};
  bool isLoading = true;
  String? error;
  int selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final cars = await CarService.getAllCars();

      setState(() {
        allCars = cars;
        displayedCars = CarService.getFeaturedCars(cars);
        nearbyCars = CarService.getCarsByLocation(cars, 'Maputo');
        availableBrands = CarService.getUniqueBrands(cars);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onBrandSelected(String brand) {
    setState(() {
      selectedBrand = selectedBrand == brand ? null : brand;
      if (selectedBrand != null) {
        displayedCars = CarService.filterCarsByBrand(allCars, selectedBrand!);
      } else {
        displayedCars = CarService.getFeaturedCars(allCars);
      }
    });
  }

  void _toggleFavorite(String carId) {
    setState(() {
      if (favoriteCars.contains(carId)) {
        favoriteCars.remove(carId);
      } else {
        favoriteCars.add(carId);
      }
    });
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      selectedBottomIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        _navigateToSearch();
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatsScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReservationsScreen()));
        break;
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
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Koila', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _navigateToSearch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text('Procure pelo seu carro...', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
              const Spacer(),
              Icon(Icons.tune, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Erro ao carregar dados', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(error!, style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildBrandsSection(),
            const SizedBox(height: 30),
            _buildFeaturedCarsSection(),
            const SizedBox(height: 30),
            _buildNearbyCarsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsSection() {
    if (availableBrands.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Marcas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: availableBrands.length,
            itemBuilder: (context, index) {
              final brand = availableBrands[index];
              final isSelected = selectedBrand == brand;

              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _onBrandSelected(brand),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                    ),
                    child: Text(
                      brand,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarsSection() {
    if (displayedCars.isEmpty) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedBrand != null ? '$selectedBrand Carros' : 'Carros em Destaque',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
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
            itemCount: displayedCars.length,
            itemBuilder: (context, index) {
              final car = displayedCars[index];
              return _buildCarCard(car);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCarsSection() {
    if (nearbyCars.isEmpty) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Carros em destaque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
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
            itemCount: nearbyCars.length,
            itemBuilder: (context, index) {
              final car = nearbyCars[index];
              return _buildCarCard(car);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(ApiCar car) {
    final isFavorite = favoriteCars.contains(car.id);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showCarDetails(car),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: car.hasImages
                        ? DecorationImage(image: NetworkImage(car.firstImageUrlFixed), fit: BoxFit.cover)
                        : null,
                  ),
                  child: !car.hasImages
                      ? const Center(child: Icon(Icons.directions_car, size: 60, color: Colors.grey))
                      : null,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(car.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.yearAndColor,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          car.localizacao,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.pricePerDayFormatted,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.search, 1),
          _buildNavItem(Icons.email, 2),
          _buildNavItem(Icons.notifications, 3),
          _buildNavItem(Icons.person, 4),
          _buildNavItem(Icons.bookmark, 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedBottomIndex == index;

    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  void _showCarDetails(ApiCar car) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
    );
  }
}