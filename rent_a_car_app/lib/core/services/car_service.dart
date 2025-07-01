import 'package:rent_a_car_app/models/brand.dart';
import 'package:rent_a_car_app/models/car.dart';

/// Serviço responsável por fornecer dados dos carros
///  chamadas_API
class CarService {
  /// Retorna lista de marcas disponíveis
  static List<Brand> getBrands() {
    return [
      Brand(name: 'Mazda', logoUrl: 'assets/brands/mazda', slug: 'Mazda'),
      Brand(name: 'VW', logoUrl: 'assets/brands/vw.png', slug: 'vw'),
      Brand(name: 'BMW', logoUrl: 'assets/brands/bmw.png', slug: 'bmw'),
      Brand(
        name: 'Nissan',
        logoUrl: 'assets/brands/nissan.png',
        slug: 'nissan',
      ),
    ];
  }

  /// Retorna lista de carros em destaque (Best Cars)
  static List<Car> getBestCars() {
    return [
      Car(
        id: '1',
        name: 'tesla - LL',
        brand: 'tesla',
        imageUrl: 'assets/cars/tesla.png',
        rating: 5.0,
        location: 'Maputo',
        pricePerDay: 200,
        seats: 4,
        category: 'luxuoso',
      ),
      Car(
        id: '2',
        name: 'Mazda Veriza',
        brand: 'Mazda',
        imageUrl: 'assets/cars/mazda.png',
        rating: 5.0,
        location: 'Quelimane',
        pricePerDay: 100,
        seats: 5,
        category: 'electrico',
      ),
    ];
  }

  /// Retorna lista de carros próximos (Nearby)
  static List<Car> getNearbyCars() {
    return [
      Car(
        id: '3',
        name: 'BMW M4',
        brand: 'BMW',
        imageUrl: 'assets/cars/bmw.png',
        rating: 4.8,
        location: 'Maputo',
        pricePerDay: 150,
        seats: 4,
        category: 'Esportivo',
      ),
    ];
  }

  /// Retorna carros recomendados para o usuário
  static List<Car> getRecommendedCars() {
    return [
      Car(
        id: '4',
        name: 'Tesla Model S',
        brand: 'Tesla',
        imageUrl: 'assets/cars/tesla.png',
        rating: 5.0,
        location: 'Maputo',
        pricePerDay: 100,
        seats: 5,
        category: 'electrico',
      ),
      Car(
        id: '5',
        name: 'Mazda demio',
        brand: 'Mazda',
        imageUrl: 'assets/cars/mazda.png',
        rating: 5.0,
        location: 'Gza',
        pricePerDay: 400,
        seats: 2,
        category: 'supercar',
      ),
    ];
  }

  /// Retorna carros populares
  static List<Car> getPopularCars() {
    return [
      Car(
        id: '6',
        name: 'Lamborghini Aventador',
        brand: 'Lamborghini',
        imageUrl: 'assets/cars/lamborghini_aventador.png',
        rating: 4.9,
        location: 'Gaza',
        pricePerDay: 350,
        seats: 2,
        category: 'supercar',
      ),
      Car(
        id: '7',
        name: 'BMW GT53 M2',
        brand: 'BMW',
        imageUrl: 'assets/cars/bmw_gt53.png',
        rating: 4.7,
        location: 'BEira',
        pricePerDay: 180,
        seats: 4,
        category: 'sport',
      ),
    ];
  }

  /// Filtra carros por marca
  static List<Car> getCarsByBrand(String brand) {
    final allCars = [
      ...getBestCars(),
      ...getNearbyCars(),
      ...getRecommendedCars(),
      ...getPopularCars(),
    ];

    return allCars
        .where((car) => car.brand.toLowerCase() == brand.toLowerCase())
        .toList();
  }

  /// Busca carros por texto
  static List<Car> searchCars(String query) {
    final allCars = [
      ...getBestCars(),
      ...getNearbyCars(),
      ...getRecommendedCars(),
      ...getPopularCars(),
    ];

    return allCars
        .where(
          (car) =>
              car.name.toLowerCase().contains(query.toLowerCase()) ||
              car.brand.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
