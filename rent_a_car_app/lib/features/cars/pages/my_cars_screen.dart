import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/car_model.dart';
import 'package:rent_a_car_app/core/services/car_service.dart';
import 'package:rent_a_car_app/features/cars/widgets/empty_my_cars_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/error_my_cars_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/my_car_list_item.dart';
import 'package:rent_a_car_app/features/cars/widgets/my_cars_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<ApiCar> _myCars = [];
  bool _isLoading = true;
  String? _error;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadMyCars();
  }

  Future<void> _loadMyCars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Pega o ID do usuário logado
      await _getCurrentUserId();

      // Carrega todos os carros (retorna e atualiza cache)
      final allCars = await CarService.getAllCars();

      // Filtra pelos carros do proprietário logado
      final myCars = CarService.getCarsByOwner(allCars, _currentUserId);

      setState(() {
        _myCars = myCars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      final decodedToken = JwtDecoder.decode(token);
      _currentUserId = decodedToken['id'] ?? decodedToken['userId'] ?? '';
    }
  }

  Future<void> _refresh() async {
    await _loadMyCars();
  }

  void _navigateToDetails(ApiCar car) async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CarDetailsScreen(car: car),
    //   ),
    // );

    // Por enquanto, mostra um SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes de ${car.marca} ${car.modelo}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEdit(ApiCar car) async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditCarScreen(car: car),
    //   ),
    // );

    // Por enquanto, mostra um SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${car.marca} ${car.modelo}'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteCar(ApiCar car) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Veículo'),
        content: Text(
          'Tem certeza que deseja excluir ${car.marca} ${car.modelo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Remove da lista local
      setState(() {
        _myCars.removeWhere((c) => c.id == car.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veículo excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleAvailability(ApiCar car) async {
    // Atualiza apenas a lista local (já que não temos acesso ao cache privado)
    setState(() {
      final index = _myCars.indexWhere((c) => c.id == car.id);
      if (index != -1) {
        _myCars[index] = _createUpdatedCar(car, !car.disponibilidade);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          car.disponibilidade
              ? 'Veículo marcado como indisponível'
              : 'Veículo marcado como disponível',
        ),
        backgroundColor: car.disponibilidade ? Colors.orange : Colors.green,
      ),
    );
  }

  // Helper para criar carro atualizado (já que ApiCar é imutável)
  ApiCar _createUpdatedCar(ApiCar original, bool newAvailability) {
    // Se você tiver um método copyWith no ApiCar, use:
    // return original.copyWith(disponibilidade: newAvailability);

    // Se não, você pode recriar usando fromJson/toJson:
    final json = original.toJson();
    json['disponibilidade'] = newAvailability;
    return ApiCar.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            MyCarsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_error != null) {
      return ErrorMyCarsState(error: _error!, onRetry: _refresh);
    }

    if (_myCars.isEmpty) {
      return const EmptyMyCarsState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _myCars.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final car = _myCars[index];
        return MyCarListItem(
          car: car,
          onTap: () => _navigateToDetails(car),
          onEdit: () => _navigateToEdit(car),
          onDelete: () => _deleteCar(car),
          onToggleAvailability: () => _toggleAvailability(car),
        );
      },
    );
  }
}
