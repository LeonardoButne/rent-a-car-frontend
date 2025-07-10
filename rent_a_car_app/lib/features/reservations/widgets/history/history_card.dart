import 'package:flutter/material.dart';
import 'package:rent_a_car_app/models/rental_history.dart';

/// Card individual do histórico
class HistoryCard extends StatelessWidget {
  final RentalHistory rental;
  final VoidCallback? onTap;
  final bool isOwner;

  const HistoryCard({super.key, required this.rental, this.onTap, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildCarImage(),
            const SizedBox(width: 16),
            Expanded(child: _buildCarInfo()),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: rental.carImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                rental.carImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.directions_car, size: 30, color: Colors.grey[400]),
              ),
            )
          : Center(
              child: Icon(Icons.directions_car, size: 30, color: Colors.grey[400]),
            ),
    );
  }

  Widget _buildCarInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rental.carName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rental.carBrand,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (isOwner) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  rental.clientName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              _formatDateRange(),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.currency_exchange, size: 12, color: Colors.grey[400]),
            Text(
              'MZN ${rental.totalValue.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (rental.userRating != null) ...[
              const SizedBox(width: 12),
              Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                rental.userRating!.toStringAsFixed(1),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rental.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rental.statusText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: rental.statusColor,
        ),
      ),
    );
  }

  String _formatDateRange() {
    final start = '${rental.startDate.day}/${rental.startDate.month}';
    final end = '${rental.endDate.day}/${rental.endDate.month}';
    return '$start - $end';
  }
}
