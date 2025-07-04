import 'package:flutter/material.dart';

class EmptyRequestedReservationsState extends StatelessWidget {
  final String filter;

  const EmptyRequestedReservationsState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    String message;
    String description;
    IconData icon;

    switch (filter) {
      case 'pending':
        message = 'Nenhuma solicitação pendente';
        description = 'Novas solicitações aparecerão aqui';
        icon = Icons.pending_actions;
        break;
      case 'approved':
        message = 'Nenhuma reserva aprovada';
        description = 'Reservas aprovadas aparecerão aqui';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        message = 'Nenhuma reserva rejeitada';
        description = 'Reservas rejeitadas aparecerão aqui';
        icon = Icons.cancel;
        break;
      default:
        message = 'Nenhuma solicitação encontrada';
        description = 'Aguarde por novas solicitações!';
        icon = Icons.inbox;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
