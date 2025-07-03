import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:intl/intl.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late Future<List<Reservation>> _futureReservations;

  @override
  void initState() {
    super.initState();
    _futureReservations = ReservationService.getMyReservations();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReservations = ReservationService.getMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Reservation>>(
          future: _futureReservations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            final reservations = snapshot.data ?? [];
            if (reservations.isEmpty) {
              return const Center(child: Text('Nenhuma reserva encontrada.'));
            }
            return ListView.separated(
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = reservations[index];
                Color statusColor;
                switch (r.status) {
                  case 'pending':
                    statusColor = Colors.orange;
                    break;
                  case 'approved':
                    statusColor = Colors.green;
                    break;
                  case 'rejected':
                    statusColor = Colors.red;
                    break;
                  case 'cancelled':
                    statusColor = Colors.grey;
                    break;
                  default:
                    statusColor = Colors.blueGrey;
                }
                final car = r.car;
                final owner = r.owner;
                final imageUrl = car != null && car.images.isNotEmpty ? fixImageUrl(car.images.first.url) : null;
                return ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[200],
                              child: const Icon(Icons.directions_car, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_car, color: Colors.grey),
                        ),
                  title: car != null
                      ? Text('${car.marca} ${car.modelo} (${car.cor})', style: const TextStyle(fontWeight: FontWeight.bold))
                      : Text('Carro ${r.carId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reserva #${r.id.substring(0, 8)}'),
                      if (car != null) Text('Placa: ${car.placa}'),
                      Text('De: ${DateFormat('dd/MM/yyyy').format(r.startDate)} até ${DateFormat('dd/MM/yyyy').format(r.endDate)}'),
                      if (owner != null) Text('Proprietario: ${owner.name} ${owner.lastName}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(r.status, style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      )),
                      Text('MT ${r.price.toStringAsFixed(0)}'),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailsScreen(reservationId: r.id),
                      ),
                    );
                    if (result == true) {
                      _refresh();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Função mock para buscar nome/modelo do carro pelo carId (substitua por busca real se necessário)
  String getCarName(String carId) {
    // Aqui você pode buscar o nome/modelo real do carro se tiver os dados
    return 'Carro $carId';
  }

  String fixImageUrl(String url) {
    if (url.startsWith('http')) {
      // Se já for uma URL absoluta, só faz o replace se for localhost
      return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
    } else {
      // Se for um path relativo, monta com baseUrl
      return '$baseUrl/$url';
    }
  }
}

class ReservationDetailsScreen extends StatefulWidget {
  final String reservationId;
  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late Future<Reservation> _futureReservation;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _futureReservation = ReservationService.getReservationById(widget.reservationId);
  }

  Future<void> _cancelReservation() async {
    setState(() { _isCancelling = true; });
    try {
      await ReservationService.cancelReservation(widget.reservationId);
      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para atualizar lista
      }
    } catch (e) {
      setState(() { _isCancelling = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cancelar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Reserva'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Reservation>(
        future: _futureReservation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final r = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reserva #${r.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Carro: ${r.car?.marca}'),
                Text('Proprietario: ${r.owner?.name} ${r.owner?.lastName}'),
                Text('De: ${DateFormat('dd/MM/yyyy').format(r.startDate)}'),
                Text('Até: ${DateFormat('dd/MM/yyyy').format(r.endDate)}'),
                Text('Status: ${r.status}'),
                Text('Preço: MT ${r.price.toStringAsFixed(0)}'),
                if (r.notes != null && r.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Observação: ${r.notes}'),
                ],
                const Spacer(),
                if (r.status == 'pending' || r.status == 'approved')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCancelling ? null : _cancelReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Cancelar Reserva'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
} 