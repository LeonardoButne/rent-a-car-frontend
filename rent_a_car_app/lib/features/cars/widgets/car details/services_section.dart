import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/car_model.dart';

class ServicesSection extends StatelessWidget {
  final ApiCar car;

  const ServicesSection({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final services = _getAvailableServices();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.room_service,
              color: Colors.orange,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Serviços',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: services
                      .map((service) => _buildServiceChip(service))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(ServiceInfo service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: service.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(service.icon, color: service.color, size: 12),
          const SizedBox(width: 4),
          Text(
            service.name,
            style: TextStyle(
              color: service.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  List<ServiceInfo> _getAvailableServices() {
    List<ServiceInfo> services = [];
    final serviceType = car.serviceType.toLowerCase();

    if (serviceType.contains('aluguel') ||
        serviceType.contains('rental') ||
        serviceType.isEmpty) {
      services.add(
        ServiceInfo(
          name: 'Aluguel',
          icon: Icons.car_rental,
          color: Colors.blue,
        ),
      );
    }

    if (serviceType.contains('logística') ||
        serviceType.contains('logistica') ||
        serviceType.contains('logistics')) {
      services.add(
        ServiceInfo(
          name: 'Logística',
          icon: Icons.local_shipping,
          color: Colors.orange,
        ),
      );
    }

    if (serviceType.contains('ambos') || serviceType.contains('both')) {
      services.clear();
      services.addAll([
        ServiceInfo(
          name: 'Aluguel',
          icon: Icons.car_rental,
          color: Colors.blue,
        ),
        ServiceInfo(
          name: 'Logística',
          icon: Icons.local_shipping,
          color: Colors.orange,
        ),
      ]);
    }

    if (services.isEmpty) {
      services.add(
        ServiceInfo(
          name: 'Aluguel',
          icon: Icons.car_rental,
          color: Colors.blue,
        ),
      );
    }

    return services;
  }
}

// ===========================
// 📁 Modelo simples para os Serviços
// ===========================

class ServiceInfo {
  final String name;
  final IconData icon;
  final Color color;

  ServiceInfo({required this.name, required this.icon, required this.color});
}
