import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';

class CarInfoCard extends StatelessWidget {
  final Reservation reservation;

  const CarInfoCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final car = reservation.car;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Veículo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (car != null) ...[
            Text(
              '${car.marca} ${car.modelo}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCarDetail('Cor', car.cor),
                const SizedBox(width: 20),
                _buildCarDetail('Placa', car.placa),
              ],
            ),
          ] else ...[
            Text('Carro ID: ${reservation.carId}'),
          ],
        ],
      ),
    );
  }

  Widget _buildCarDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
