import 'package:flutter/material.dart';
import 'package:rent_a_car_app/widgets/car%20details/feature_item.dart';
import '../../models/car.dart';

class CarFeaturesSection extends StatelessWidget {
  final Car car;

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
                  value: '${car.seats} Assentos',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.speed,
                  title: 'Saída de Cruzeiro',
                  value: '670 HP',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.flash_on,
                  title: 'Velocidade Máx',
                  value: '250km/h',
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
                  title: 'Avançado',
                  value: 'Autopiloto',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.battery_charging_full,
                  title: 'Carga Única',
                  value: '405 Milhas',
                ),
              ),
              Expanded(
                child: FeatureItem(
                  icon: Icons.local_parking,
                  title: 'Avançado',
                  value: 'Estacionamento Automático',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
