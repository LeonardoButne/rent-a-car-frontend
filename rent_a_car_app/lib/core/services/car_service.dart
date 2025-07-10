// services/car_service.dart

import 'package:dio/dio.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';

import '../../models/brand.dart';
import '../models/car_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/base_url.dart';

class CarService {
  static final ApiService _apiService = ApiService();
  static List<ApiCar> _cachedCars = [];
  static List<Brand> _cachedBrands = [];

  // ========== API METHODS ==========

  // Get all cars
  static Future<List<ApiCar>> getAllCars() async {
    try {
      final response = await _apiService.get('/car/cars');
      final List<dynamic> jsonData = response.data;
      _cachedCars = jsonData.map((json) => ApiCar.fromJson(json)).toList();
      return _cachedCars;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get car by ID
  static Future<ApiCar> getCarById(String carId) async {
    try {
      final response = await _apiService.get('/car/$carId');
      final Map<String, dynamic> jsonData = response.data;
      return ApiCar.fromJson(jsonData);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ========== METHODS FOR SEARCHSCREEN ==========

  // Get recommended cars (featured cars)
  static List<ApiCar> getRecommendedCars() {
    if (_cachedCars.isEmpty) {
      return [];
    }

    return _cachedCars
        .where((car) => car.featured)
        .take(6)
        .toList();
  }

  // Get popular cars (sorted by creation date - newest first)
  static List<ApiCar> getPopularCars() {
    if (_cachedCars.isEmpty) {
      return [];
    }

    var sortedCars = List<ApiCar>.from(_cachedCars);
    sortedCars.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedCars.take(8).toList();
  }

  // Get available brands
  static List<Brand> getBrands() {
    if (_cachedCars.isEmpty) {
      return [];
    }

    // Extract unique brands from cars
    final uniqueBrands = <String, Brand>{};

    for (var car in _cachedCars) {
      if (!uniqueBrands.containsKey(car.marca)) {
        uniqueBrands[car.marca] = Brand(
          id: car.marca.toLowerCase().replaceAll(' ', '_'),
          name: car.marca,
          slug: car.marca.toLowerCase().replaceAll(' ', '_'),
          logoUrl: 'assets/brands/${car.marca.toLowerCase().replaceAll(' ', '_')}_logo.png',
        );
      }
    }

    _cachedBrands = uniqueBrands.values.toList();
    _cachedBrands.sort((a, b) => a.name.compareTo(b.name));

    return _cachedBrands;
  }

  // Search cars by term
  static List<ApiCar> searchCars(String query) {
    if (_cachedCars.isEmpty) {
      return [];
    }

    return searchCarsFromApiList(_cachedCars, query);
  }

  // Get cars by brand
  static List<ApiCar> getCarsByBrand(String brandSlug) {
    if (_cachedCars.isEmpty) {
      return [];
    }

    final brandName = brandSlug.replaceAll('_', ' ');
    return filterCarsByBrand(_cachedCars, brandName);
  }

  // ========== FILTER METHODS (API) ==========

  // Filter cars by brand
  static List<ApiCar> filterCarsByBrand(List<ApiCar> cars, String brand) {
    return cars.where((car) =>
    car.marca.toLowerCase() == brand.toLowerCase()
    ).toList();
  }

  // Get featured cars
  static List<ApiCar> getFeaturedCars(List<ApiCar> cars) {
    return cars.where((car) => car.featured).toList();
  }

  // Get cars by location
  static List<ApiCar> getCarsByLocation(List<ApiCar> cars, String location) {
    return cars.where((car) =>
        car.localizacao.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  // Filter cars by price range
  static List<ApiCar> filterCarsByPriceRange(
      List<ApiCar> cars,
      double minPrice,
      double maxPrice
      ) {
    return cars.where((car) =>
    car.precoPorDia >= minPrice && car.precoPorDia <= maxPrice
    ).toList();
  }

  // Filter cars by year
  static List<ApiCar> filterCarsByYear(List<ApiCar> cars, int minYear, int maxYear) {
    return cars.where((car) =>
    car.ano >= minYear && car.ano <= maxYear
    ).toList();
  }

  // Filter cars by fuel type
  static List<ApiCar> filterCarsByFuelType(List<ApiCar> cars, String fuelType) {
    return cars.where((car) =>
    car.combustivel.toLowerCase() == fuelType.toLowerCase()
    ).toList();
  }

  // Filter cars by transmission
  static List<ApiCar> filterCarsByTransmission(List<ApiCar> cars, String transmission) {
    return cars.where((car) =>
    car.transmissao.toLowerCase() == transmission.toLowerCase()
    ).toList();
  }

  // Filter cars by class
  static List<ApiCar> filterCarsByClass(List<ApiCar> cars, String carClass) {
    return cars.where((car) =>
    car.classe.toLowerCase() == carClass.toLowerCase()
    ).toList();
  }

  // Filter cars by category
  static List<ApiCar> filterCarsByCategory(List<ApiCar> cars, String category) {
    return cars.where((car) =>
        car.categorias.toLowerCase().contains(category.toLowerCase())
    ).toList();
  }

  // Get available cars
  static List<ApiCar> getAvailableCars(List<ApiCar> cars) {
    return cars.where((car) => car.disponibilidade).toList();
  }

  // Search cars by term
  static List<ApiCar> searchCarsFromApiList(List<ApiCar> cars, String searchTerm) {
    final term = searchTerm.toLowerCase();
    return cars.where((car) =>
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

  // ========== UTILITY METHODS ==========

  // Get unique brands
  static List<String> getUniqueBrands(List<ApiCar> cars) {
    return cars.map((car) => car.marca).toSet().toList()..sort();
  }

  // Get unique models for a specific brand
  static List<String> getModelsForBrand(List<ApiCar> cars, String brand) {
    return cars
        .where((car) => car.marca.toLowerCase() == brand.toLowerCase())
        .map((car) => car.modelo)
        .toSet()
        .toList()
      ..sort();
  }

  // Get unique locations
  static List<String> getUniqueLocations(List<ApiCar> cars) {
    return cars.map((car) => car.localizacao).toSet().toList()..sort();
  }

  // Get unique classes
  static List<String> getUniqueClasses(List<ApiCar> cars) {
    return cars.map((car) => car.classe).toSet().toList()..sort();
  }

  // Get unique categories
  static List<String> getUniqueCategories(List<ApiCar> cars) {
    final categories = <String>{};
    for (var car in cars) {
      final carCategories = car.categorias.split(',').map((c) => c.trim());
      categories.addAll(carCategories);
    }
    return categories.toList()..sort();
  }

  // Get unique fuel types
  static List<String> getUniqueFuelTypes(List<ApiCar> cars) {
    return cars.map((car) => car.combustivel).toSet().toList()..sort();
  }

  // Get unique transmissions
  static List<String> getUniqueTransmissions(List<ApiCar> cars) {
    return cars.map((car) => car.transmissao).toSet().toList()..sort();
  }

  // Get basic statistics
  static Map<String, dynamic> getCarStatistics(List<ApiCar> cars) {
    if (cars.isEmpty) return {};

    final prices = cars.map((car) => car.precoPorDia).toList();
    final years = cars.map((car) => car.ano).toList();
    final mileages = cars.map((car) => car.quilometragem).toList();

    return {
      'totalCars': cars.length,
      'availableCars': cars.where((car) => car.disponibilidade).length,
      'featuredCars': cars.where((car) => car.featured).length,
      'averagePrice': prices.reduce((a, b) => a + b) / prices.length,
      'minPrice': prices.reduce((a, b) => a < b ? a : b),
      'maxPrice': prices.reduce((a, b) => a > b ? a : b),
      'averageYear': years.reduce((a, b) => a + b) / years.length,
      'averageMileage': mileages.reduce((a, b) => a + b) / mileages.length,
      'uniqueBrands': getUniqueBrands(cars).length,
      'uniqueLocations': getUniqueLocations(cars).length,
      'uniqueClasses': getUniqueClasses(cars).length,
      'uniqueCategories': getUniqueCategories(cars).length,
    };
  }

  // ========== ADDITIONAL METHODS ==========

  // Get cars by owner
  static List<ApiCar> getCarsByOwner(List<ApiCar> cars, String ownerId) {
    return cars.where((car) => car.ownerId == ownerId).toList();
  }

  // Get cars created in a period
  static List<ApiCar> getCarsCreatedBetween(
      List<ApiCar> cars,
      DateTime startDate,
      DateTime endDate
      ) {
    return cars.where((car) =>
    car.createdAt.isAfter(startDate) && car.createdAt.isBefore(endDate)
    ).toList();
  }

  // Filter cars by mileage range
  static List<ApiCar> filterCarsByMileage(
      List<ApiCar> cars,
      int minMileage,
      int maxMileage
      ) {
    return cars.where((car) =>
    car.quilometragem >= minMileage && car.quilometragem <= maxMileage
    ).toList();
  }

  // Get cars sorted by price
  static List<ApiCar> getCarsSortedByPrice(List<ApiCar> cars, {bool ascending = true}) {
    var sortedCars = List<ApiCar>.from(cars);
    if (ascending) {
      sortedCars.sort((a, b) => a.precoPorDia.compareTo(b.precoPorDia));
    } else {
      sortedCars.sort((a, b) => b.precoPorDia.compareTo(a.precoPorDia));
    }
    return sortedCars;
  }

  // Get cars sorted by year
  static List<ApiCar> getCarsSortedByYear(List<ApiCar> cars, {bool newestFirst = true}) {
    var sortedCars = List<ApiCar>.from(cars);
    if (newestFirst) {
      sortedCars.sort((a, b) => b.ano.compareTo(a.ano));
    } else {
      sortedCars.sort((a, b) => a.ano.compareTo(b.ano));
    }
    return sortedCars;
  }

  static Future<List<ApiCar>> getMyCars() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/owner/my-cars'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ApiCar.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar seus carros');
    }
  }

  // Handle Dio errors
  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout';
      case DioExceptionType.connectionError:
        return 'Server connection error';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error: ${e.message}';
    }
  }
}