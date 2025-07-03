import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/car_details_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/profile/profile_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/search_screen.dart';
import 'package:rent_a_car_app/features/auth/pages/my_reservations_screen.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import '../../../core/models/car_model.dart';
import '../../../core/services/car_service.dart';
import 'notifications/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? selectedBrand;
  String selectedServiceType = 'aluguer';
  List<ApiCar> allCars = [];
  List<ApiCar> featuredCars = [];
  List<ApiCar> logisticsCars = [];
  List<ApiCar> nearbyCars = [];
  List<ApiCar> recentCars = [];
  List<String> availableBrands = [];
  Set<String> favoriteCars = {};
  List<ApiCar> generalCars = [];
  List<ApiCar> filteredCars = [];
  bool isLoading = true;
  String? error;
  int selectedBottomIndex = 0;
  late TabController _serviceTabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Adicionando controle de operações assíncronas
  Completer<void>? _loadDataCompleter;
  Timer? _debounceTimer;

  final List<Map<String, dynamic>> quickActions = [
    {'icon': Icons.search, 'title': 'Pesquisar', 'color': Colors.black},
    {'icon': Icons.local_shipping, 'title': 'Logística', 'color': Colors.black},
    {'icon': Icons.history, 'title': 'Histórico', 'color': Colors.black},
    {'icon': Icons.favorite_outline, 'title': 'Favoritos', 'color': Colors.black},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
    selectedBottomIndex = 0;
  }

  void _initializeControllers() {
    try {
      _serviceTabController = TabController(length: 2, vsync: this);
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    } catch (e) {
      developer.log('Erro ao inicializar controllers: $e', name: 'HomeScreen');
    }
  }

  @override
  void dispose() {
    try {
      // Cancelar operações em andamento
      _loadDataCompleter?.complete();
      _debounceTimer?.cancel();

      // Limpar controllers
      _serviceTabController.dispose();
      _animationController.dispose();

      // Limpar listas para liberar memória
      allCars.clear();
      featuredCars.clear();
      logisticsCars.clear();
      nearbyCars.clear();
      recentCars.clear();
      availableBrands.clear();
      favoriteCars.clear();
      generalCars.clear();

      developer.log('HomeScreen dispose concluído', name: 'HomeScreen');
    } catch (e) {
      developer.log('Erro durante dispose: $e', name: 'HomeScreen');
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    // Cancelar carregamento anterior se ainda estiver em andamento
    if (_loadDataCompleter != null && !_loadDataCompleter!.isCompleted) {
      _loadDataCompleter!.complete();
    }

    _loadDataCompleter = Completer<void>();

    try {
      developer.log('Iniciando carregamento de dados', name: 'HomeScreen');

      if (!mounted) return;

      setState(() {
        isLoading = true;
        error = null;
      });

      // Adicionar timeout para prevenir travamento
      final cars = await CarService.getAllCars()
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      developer.log('${cars.length} carros carregados', name: 'HomeScreen');

      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 7));

      // Verificar se o widget ainda está montado antes de cada operação
      if (!mounted) return;

      final processedData = _processCarData(cars, cutoffDate);

      if (!mounted) return;

      setState(() {
        allCars = cars;
        featuredCars = processedData['featured'];
        logisticsCars = processedData['logistics'];
        nearbyCars = processedData['nearby'];
        recentCars = processedData['recent'];
        generalCars = processedData['general'];
        availableBrands = processedData['brands'];
        isLoading = false;
      });

      if (!mounted) return;

      // Iniciar animação com segurança
      try {
        await _animationController.forward();
      } catch (e) {
        developer.log('Erro na animação: $e', name: 'HomeScreen');
      }

      developer.log('Carregamento concluído com sucesso', name: 'HomeScreen');

    } on TimeoutException {
      if (!mounted) return;

      developer.log('Timeout no carregamento de dados', name: 'HomeScreen');

      setState(() {
        error = 'Timeout: Verifique sua conexão com a internet';
        isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;

      developer.log('Erro ao carregar dados: $e', name: 'HomeScreen', stackTrace: stackTrace);

      setState(() {
        error = _getErrorMessage(e);
        isLoading = false;
      });
    } finally {
      if (!_loadDataCompleter!.isCompleted) {
        _loadDataCompleter!.complete();
      }
    }
  }

  Map<String, dynamic> _processCarData(List<ApiCar> cars, DateTime cutoffDate) {
    try {
      final featured = cars.where((car) => car.featured == true).toList();
      final logistics = cars.where((car) => car.serviceType == 'logistica').toList();
      final nearby = CarService.getCarsByLocation(cars, 'Maputo');

      // Processamento seguro de carros recentes
      final recent = cars.where((car) {
        return car.createdAt?.isAfter(cutoffDate) ?? false;
      }).take(10).toList();

      final recentToUse = recent.isNotEmpty ? recent : cars.take(5).toList();

      // Processamento seguro de carros gerais
      final recentCarIds = recentToUse.map((car) => car.id).toSet();
      final featuredCarIds = featured.map((car) => car.id).toSet();
      final nearbyCarIds = nearby.map((car) => car.id).toSet();

      final general = cars.where((car) {
        return !recentCarIds.contains(car.id) &&
            !featuredCarIds.contains(car.id) &&
            !nearbyCarIds.contains(car.id) &&
            car.serviceType != 'logistica';
      }).toList();

      final brands = CarService.getUniqueBrands(cars);

      return {
        'featured': featured,
        'logistics': logistics,
        'nearby': nearby,
        'recent': recentToUse,
        'general': general,
        'brands': brands,
      };
    } catch (e) {
      developer.log('Erro ao processar dados dos carros: $e', name: 'HomeScreen');
      return {
        'featured': <ApiCar>[],
        'logistics': <ApiCar>[],
        'nearby': <ApiCar>[],
        'recent': <ApiCar>[],
        'general': <ApiCar>[],
        'brands': <String>[],
      };
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'Sem conexão com a internet';
    } else if (error is TimeoutException) {
      return 'Timeout: Operação demorou muito para responder';
    } else if (error is FormatException) {
      return 'Erro no formato dos dados recebidos';
    } else {
      return 'Erro inesperado: ${error.toString()}';
    }
  }
  void _applyBrandFilter() {
    if (selectedBrand == null) {
      // Se nenhuma marca selecionada, usar listas originais
      filteredCars = [];
    } else {
      // Filtrar todos os carros pela marca selecionada
      filteredCars = allCars.where((car) =>
      car.marca.toLowerCase() == selectedBrand!.toLowerCase()
      ).toList();
    }
  }

  void _onBrandSelected(String brand) {
    if (!mounted) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        selectedBrand = selectedBrand == brand ? null : brand;
        _applyBrandFilter();
      });
    });
  }

  void _onServiceTypeChanged(String serviceType) {
    if (!mounted) return;

    setState(() {
      selectedServiceType = serviceType;
    });
  }

  void _toggleFavorite(String carId) {
    if (!mounted) return;

    setState(() {
      if (favoriteCars.contains(carId)) {
        favoriteCars.remove(carId);
      } else {
        favoriteCars.add(carId);
      }
    });

    // Feedback com verificação de contexto
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favoriteCars.contains(carId)
                ? 'Adicionado aos favoritos!'
                : 'Removido dos favoritos!',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToSearch() {
    if (!mounted || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _onQuickActionTap(String action) {
    if (!mounted) return;

    switch (action) {
      case 'Pesquisar':
        _navigateToSearch();
        break;
      case 'Logística':
        setState(() {
          selectedServiceType = 'logistica';
        });
        break;
      case 'Histórico':
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyReservationsScreen()),
          );
        }
        break;
      case 'Favoritos':
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favoritos em desenvolvimento')),
          );
        }
        break;
    }
  }

  void _onBottomNavTap(int index) {
    if (!mounted) return;

    if (!context.mounted) return;

    switch (index) {
      case 0:
        setState(() {
          selectedBottomIndex = 0;
        });
        break;
      case 1:
        setState(() {
          selectedBottomIndex = 1;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        ).then((_) {
          if (mounted) {
            setState(() {
              selectedBottomIndex = 0;
            });
          }
        });
        break;
      case 2:
        setState(() {
          selectedBottomIndex = 2;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) {
          if (mounted) {
            setState(() {
              selectedBottomIndex = 0;
            });
          }
        });
        break;
      case 3:
        setState(() {
          selectedBottomIndex = 3;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyReservationsScreen()),
        );
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
            _buildServiceTabs(),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Koila', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(
                'Bem-vindo de volta!',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          // Stack(
          //   children: [
          //     Container(
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.3),
          //             spreadRadius: 1,
          //             blurRadius: 5,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: const CircleAvatar(
          //         radius: 22,
          //         backgroundColor: Colors.grey,
          //         child: Icon(Icons.person, color: Colors.white, size: 26),
          //       ),
          //     ),
          //     Positioned(
          //       right: 0,
          //       top: 0,
          //       child: Container(
          //         width: 14,
          //         height: 14,
          //         decoration: BoxDecoration(
          //           color: Colors.red,
          //           shape: BoxShape.circle,
          //           border: Border.all(color: Colors.white, width: 2),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: _navigateToSearch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[400], size: 24),
              const SizedBox(width: 15),
              Text(
                'Procure pelo seu carro ideal...',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.tune, color: Colors.grey[600], size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                try {
                  _serviceTabController.animateTo(0);
                  _onServiceTypeChanged('aluguer');
                } catch (e) {
                  developer.log('Erro ao mudar para aba aluguer: $e', name: 'HomeScreen');
                }
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selectedServiceType == 'aluguer' ? Colors.black : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Aluguer',
                    style: TextStyle(
                      color: selectedServiceType == 'aluguer' ? Colors.white : Colors.grey[600],
                      fontWeight: selectedServiceType == 'aluguer' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                try {
                  _serviceTabController.animateTo(1);
                  _onServiceTypeChanged('logistica');
                } catch (e) {
                  developer.log('Erro ao mudar para aba logística: $e', name: 'HomeScreen');
                }
              },
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selectedServiceType == 'logistica' ? Colors.black : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Logística',
                    style: TextStyle(
                      color: selectedServiceType == 'logistica' ? Colors.white : Colors.grey[600],
                      fontWeight: selectedServiceType == 'logistica' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 16),
            Text('Carregando veículos...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Ops! Algo deu errado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                error!,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildQuickActions(),
              const SizedBox(height: 25),
              if (availableBrands.isNotEmpty) ...[
                _buildBrandsSection(),
                const SizedBox(height: 25),
              ],

              // Se uma marca estiver selecionada, mostrar apenas carros filtrados
              if (selectedBrand != null) ...[
                if (filteredCars.isNotEmpty) ...[
                  _buildFilteredCarsSection(),
                  const SizedBox(height: 25),
                ] else ...[
                  _buildNoResultsSection(),
                  const SizedBox(height: 25),
                ],
              ] else ...[
                // Mostrar seções normais quando nenhuma marca está selecionada
                if (selectedServiceType == 'aluguer') ...[
                  if (featuredCars.isNotEmpty) ...[
                    _buildFeaturedCarsSection(),
                    const SizedBox(height: 25),
                  ],
                  if (nearbyCars.isNotEmpty) ...[
                    _buildNearbyCarsSection(),
                    const SizedBox(height: 25),
                  ],
                  if (recentCars.isNotEmpty) ...[
                    _buildRecentCarsSection(),
                    const SizedBox(height: 25),
                  ],
                  if (generalCars.isNotEmpty) ...[
                    _buildGeneralCarsSection(),
                    const SizedBox(height: 25),
                  ],
                ] else ...[
                  if (logisticsCars.isNotEmpty) ...[
                    _buildLogisticsCarsSection(),
                    const SizedBox(height: 25),
                  ],
                ],
              ],

              _buildPromotionalBanner(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

// Método para mostrar carros filtrados por marca
  Widget _buildFilteredCarsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$selectedBrand (${filteredCars.length})',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _onBrandSelected(selectedBrand!), // Remove filtro
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text('Limpar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: filteredCars.length,
            itemBuilder: (context, index) {
              final car = filteredCars[index];
              return _buildCarCard(car);
            },
          ),
        ),
      ],
    );
  }

// Método para mostrar quando não há resultados
  Widget _buildNoResultsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum carro encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Não encontramos carros da marca $selectedBrand',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onBrandSelected(selectedBrand!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ver todos os carros'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Ações Rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return Container(
                width: 75,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _onQuickActionTap(action['title']),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: action['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: action['color'].withOpacity(0.3)),
                        ),
                        child: Icon(
                          action['icon'],
                          color: action['color'],
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action['title'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Marcas Populares', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 55,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [Colors.black, Colors.grey])
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(27.5),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[300]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(isSelected ? 0.3 : 0.1),
                          spreadRadius: 1,
                          blurRadius: isSelected ? 8 : 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      brand,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
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
    if (featuredCars.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Carros em Destaque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text('Ver todos', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: featuredCars.length,
            itemBuilder: (context, index) {
              final car = featuredCars[index];
              return _buildCarCard(car, showFeaturedBadge: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsCarsSection() {
    if (logisticsCars.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Serviços de Logística',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve teremos veículos de logística disponíveis para você!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  const Text('Logística', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: logisticsCars.length,
            itemBuilder: (context, index) {
              final car = logisticsCars[index];
              return _buildCarCard(car, isLogistics: true);
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
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  const Text('Próximos a Você', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
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

  Widget _buildRecentCarsSection() {
    if (recentCars.isEmpty) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.fiber_new, color: Colors.purple, size: 24),
                  const SizedBox(width: 8),
                  const Text('Recém Adicionados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: recentCars.length,
            itemBuilder: (context, index) {
              final car = recentCars[index];
              return _buildCarCard(car, showNewBadge: true);
            },
          ),
        ),
      ],
    );
  }
  Widget _buildGeneralCarsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Outros Veículos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {},
                child: const Text('Ver todos', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: generalCars.length,
            itemBuilder: (context, index) {
              final car = generalCars[index];
              return _buildCarCard(car);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '🚀 Parceiro Empresarial',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tem uma frota de veículos?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Junte-se à nossa plataforma e monetize seus veículos. Milhares de clientes aguardam pelos seus serviços de qualidade.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.handshake, size: 20),
                  label: const Text('Cadastrar Empresa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  tooltip: 'Mais informações',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(ApiCar car, {bool showFeaturedBadge = false, bool showNewBadge = false, bool isLogistics = false}) {
    final isFavorite = favoriteCars.contains(car.id);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showCarDetails(car),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: car.hasImages
                        ? DecorationImage(image: NetworkImage(car.firstImageUrlFixed), fit: BoxFit.cover)
                        : null,
                  ),
                  child: !car.hasImages
                      ? Center(
                    child: Icon(
                      isLogistics ? Icons.local_shipping : Icons.directions_car,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  )
                      : null,
                ),
                if (showFeaturedBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text('Top', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (showNewBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('NOVO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (isLogistics)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_shipping, color: Colors.white, size: 10),
                          const SizedBox(width: 2),
                          Text('Log', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey[600],
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.fullName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.yearAndColor,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            car.localizacao,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            car.pricePerDayFormatted,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.black,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: const Text(
                        //     'Ver',
                        //     style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.notifications_outlined, 1),
          _buildNavItem(Icons.person_outline_rounded, 2),
          _buildNavItem(Icons.bookmark_outline_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedBottomIndex == index;

    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: isSelected ? 28 : 24,
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