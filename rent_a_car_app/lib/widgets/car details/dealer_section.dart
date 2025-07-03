import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/car_model.dart';

class DealerSection extends StatelessWidget {
  final VoidCallback onContact;
  final CarOwner owner;

  const DealerSection({
    super.key,
    required this.onContact,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onContact,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${owner.name} ${owner.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
