import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class RequestedReservationListItem extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const RequestedReservationListItem({
    super.key,
    required this.reservation,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final car = reservation.car;
    final customer =
        reservation.customer; // Assumindo que há campo customer na reserva
    final imageUrl = car?.images.isNotEmpty == true
        ? _fixImageUrl(car!.images.first.url)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildCarImage(imageUrl),
                const SizedBox(width: 16),
                Expanded(child: _buildReservationInfo(car, customer)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(reservation.status),
                    const SizedBox(height: 8),
                    Text(
                      'MT ${reservation.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDatesInfo(),
            if (reservation.status == 'pending') ...[
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarImage(String? imageUrl) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildCarPlaceholder(),
              ),
            )
          : _buildCarPlaceholder(),
    );
  }

  Widget _buildCarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.directions_car, color: Colors.grey[400], size: 30),
    );
  }

  Widget _buildReservationInfo(car, customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          car != null
              ? '${car.marca} ${car.modelo}'
              : 'Carro ${reservation.carId}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        if (car != null)
          Text(
            '${car.cor} • ${car.placa}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              customer != null ? '${customer.name}' : 'Cliente',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
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

  Widget _buildDatesInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateItem(
              'Início',
              DateFormat('dd/MM/yyyy').format(reservation.startDate),
              Icons.calendar_today,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          Expanded(
            child: _buildDateItem(
              'Fim',
              DateFormat('dd/MM/yyyy').format(reservation.endDate),
              Icons.event,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          Expanded(
            child: _buildDateItem(
              'ID',
              '#${reservation.id.substring(0, 6)}',
              Icons.tag,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.close, size: 16),
            label: const Text(
              'Rejeitar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check, size: 16),
            label: const Text(
              'Aprovar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
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

  String _fixImageUrl(String url) {
    if (url.startsWith('http')) {
      return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
    } else {
      return '$baseUrl/$url';
    }
  }
}
