import 'package:flutter/material.dart';
import '../../core/models/car_model.dart';
import '../../features/auth/pages/home_screen.dart'; // Para ApiCar
import 'package:rent_a_car_app/widgets/car%20details/feature_item.dart';

class CarFeaturesSection extends StatelessWidget {
  final ApiCar car;

  const CarFeaturesSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Características do Carro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FeatureItem(
                  icon: Icons.airline_seat_recline_normal,
                  title: 'Capacidade',
                  value: '${car.lugares} Assentos',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.speed,
                  title: 'Quilometragem',
                  value: '${car.quilometragem} km',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.flash_on,
                  title: 'Combustível',
                  value: car.combustivel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FeatureItem(
                  icon: Icons.settings,
                  title: 'Transmissão',
                  value: car.transmissao,
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.color_lens,
                  title: 'Cor',
                  value: car.cor,
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.class_,
                  title: 'Classe',
                  value: car.classe,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
