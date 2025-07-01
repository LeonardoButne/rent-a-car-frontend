import 'package:flutter/material.dart';
import '../../models/car.dart';

class CarInfoSection extends StatelessWidget {
  final Car car;

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
                car.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    car.rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(120+ Avaliações)',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            'Um carro com altas especificações que são alugados por um preço acessível.',
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
