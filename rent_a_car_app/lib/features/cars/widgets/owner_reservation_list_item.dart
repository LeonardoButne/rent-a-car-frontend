import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/owner.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

class OwnerReservationListItem extends StatelessWidget {
  final OwnerReservation reservation;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isLoadingAction;

  const OwnerReservationListItem({
    super.key,
    required this.reservation,
    required this.onTap,
    this.onApprove,
    this.onReject,
    this.isLoadingAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final car = reservation.car;
    final client = reservation.client;
    final imageUrl = car.images.isNotEmpty
        ? _fixImageUrl(car.images.first.url)
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
                Expanded(child: _buildReservationInfo(car, client)),
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
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesSection(),
            ],
            if (reservation.status.toLowerCase() == 'pending' &&
                (onApprove != null || onReject != null)) ...[
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

  Widget _buildReservationInfo(car, client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${car.marca} ${car.modelo}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${car.cor} • Placa: ${car.placa ?? 'N/A'}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              client.name,
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
              _formatDate(reservation.startDate),
              Icons.calendar_today,
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          Expanded(
            child: _buildDateItem(
              'Fim',
              _formatDate(reservation.endDate),
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

  Widget _buildNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text(
                'Observação:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reservation.notes!,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onReject != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoadingAction ? null : onReject,
              icon: isLoadingAction
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.close, size: 16),
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
        ],
        if (onApprove != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoadingAction ? null : onApprove,
              icon: isLoadingAction
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check, size: 16),
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
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _fixImageUrl(String url) {
    if (url.startsWith('http')) {
      return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
    } else {
      return '$baseUrl/$url';
    }
  }
}
