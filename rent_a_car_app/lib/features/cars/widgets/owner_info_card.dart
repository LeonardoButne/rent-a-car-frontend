import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';

class OwnerInfoCard extends StatelessWidget {
  final Reservation reservation;

  const OwnerInfoCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final owner = reservation.owner;

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
            'Proprietário',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange,
                child: Text(
                  owner?.name.isNotEmpty == true
                      ? owner!.name[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner != null
                        ? '${owner.name} ${owner.lastName}'
                        : 'Proprietário',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // no email deve ser numero de telefone....
                  if (owner?.email != null)
                    Text(
                      // no email deve ser numero de telefone
                      owner!.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
