import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';

class ReservationInfoCard extends StatelessWidget {
  final Reservation reservation;

  const ReservationInfoCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
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
            'Informações da Reserva',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReservationDetail(
                  'Data Início',
                  DateFormat('dd/MM/yyyy').format(reservation.startDate),
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildReservationDetail(
                  'Data Fim',
                  DateFormat('dd/MM/yyyy').format(reservation.endDate),
                  Icons.event,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReservationDetail(
            'Valor Total',
            'MT ${reservation.price.toStringAsFixed(0)}',
            Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
