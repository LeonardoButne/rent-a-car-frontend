import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';

class ReservationDetailsHeader extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onBack;

  const ReservationDetailsHeader({
    super.key,
    required this.reservation,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detalhes da Reserva',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: #${reservation.id.substring(0, 8)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              _buildStatusChip(reservation.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['backgroundColor'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusInfo['text'],
        style: TextStyle(
          color: statusInfo['textColor'],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'backgroundColor': Colors.orange.withOpacity(0.1),
          'textColor': Colors.orange,
          'text': 'Pendente',
        };
      case 'approved':
        return {
          'backgroundColor': Colors.green.withOpacity(0.1),
          'textColor': Colors.green,
          'text': 'Aprovada',
        };
      case 'rejected':
        return {
          'backgroundColor': Colors.red.withOpacity(0.1),
          'textColor': Colors.red,
          'text': 'Rejeitada',
        };
      case 'cancelled':
        return {
          'backgroundColor': Colors.grey.withOpacity(0.1),
          'textColor': Colors.grey,
          'text': 'Cancelada',
        };
      default:
        return {
          'backgroundColor': Colors.blue.withOpacity(0.1),
          'textColor': Colors.blue,
          'text': status,
        };
    }
  }
}
