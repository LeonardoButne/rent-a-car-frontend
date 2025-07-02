import 'package:flutter/material.dart';
import '../../core/models/car_model.dart';
import '../../features/auth/pages/home_screen.dart'; // Para ApiCar

class CarInfoSection extends StatelessWidget {
  final ApiCar car;

  const CarInfoSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                car.modelo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Remover rating se não existir em ApiCar
            ],
          ),
          const SizedBox(height: 8),
          // Remover avaliações se não existir em ApiCar
          const SizedBox(height: 16),
          Text(
            car.descricao,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
