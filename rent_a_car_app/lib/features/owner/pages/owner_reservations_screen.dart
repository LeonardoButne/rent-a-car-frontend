import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/owner_service.dart';
import 'package:rent_a_car_app/core/models/owner.dart';
import 'package:rent_a_car_app/features/cars/widgets/empty_owner_reservation_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/error_reservations_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/owner_reservation_list_item.dart';
import 'package:rent_a_car_app/features/cars/widgets/owner_reservations_header.dart';

class OwnerReservationsScreen extends StatefulWidget {
  const OwnerReservationsScreen({super.key});

  @override
  State<OwnerReservationsScreen> createState() =>
      _OwnerReservationsScreenState();
}

class _OwnerReservationsScreenState extends State<OwnerReservationsScreen> {
  late Future<List<OwnerReservation>> _futureReservations;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _futureReservations = OwnerService.getOwnerReservations();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReservations = OwnerService.getOwnerReservations();
    });
  }

  void _navigateToDetails(String reservationId) async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         OwnerReservationDetailsScreen(reservationId: reservationId),
    //   ),
    // );
    // if (result == true) {
    //   _refresh();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            OwnerReservationsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<OwnerReservation>>(
                  future: _futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      );
                    }

                    if (snapshot.hasError) {
                      return ErrorReservationsState(
                        error: snapshot.error.toString(),
                        onRetry: _refresh,
                      );
                    }

                    final reservations = snapshot.data ?? [];

                    // Filtrar apenas as reservas pendentes, ativadas e aprovadas
                    final activeReservations = reservations
                        .where((r) => r.status.toLowerCase() == 'pending' || r.status.toLowerCase() == 'active' || r.status.toLowerCase() == 'approved')
                        .toList();

                    // Ordenar da mais nova para a mais velha por data de criação
                    activeReservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (activeReservations.isEmpty) {
                      return const EmptyOwnerReservationState();
                    }

          return ListView.separated(
                      padding: const EdgeInsets.all(20),
            itemCount: activeReservations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
                        final reservation = activeReservations[index];
                        return OwnerReservationListItem(
                          reservation: reservation,
                          onTap: () async {
                            _navigateToDetails(reservation.id);
                          },
                          onApprove: reservation.status.toLowerCase() == 'pending'
                              ? () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Aprovar reserva'),
                                      content: const Text('Tem certeza que deseja aprovar esta reserva?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Aprovar', style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                  setState(() {
                                    _isLoadingAction = true;
                                  });
                                  try {
                                    await OwnerService.approveReservation(
                                      reservation.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Reserva aprovada com sucesso!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _refresh();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao aprovar reserva: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoadingAction = false;
                                    });
                                    }
                                  }
                                }
                              : null,
                          onReject: reservation.status.toLowerCase() == 'pending'
                              ? () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Rejeitar reserva'),
                                      content: const Text('Tem certeza que deseja rejeitar esta reserva?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Rejeitar', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                  setState(() {
                                    _isLoadingAction = true;
                                  });
                                  try {
                                    await OwnerService.rejectReservation(
                                      reservation.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Reserva rejeitada.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    _refresh();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erro ao rejeitar reserva: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoadingAction = false;
                                    });
                                    }
                                  }
                                }
                              : null,
                          isLoadingAction: _isLoadingAction,
                        );
                      },
                    );
                  },
                ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
