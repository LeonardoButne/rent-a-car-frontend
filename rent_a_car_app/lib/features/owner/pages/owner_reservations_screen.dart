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

                    if (reservations.isEmpty) {
                      return const EmptyOwnerReservationState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: reservations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return OwnerReservationListItem(
                          reservation: reservation,
                          onTap: () => _navigateToDetails(reservation.id),
                          onApprove:
                              reservation.status.toLowerCase() == 'pending'
                              ? () async {
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
                              : null,
                          onReject:
                              reservation.status.toLowerCase() == 'pending'
                              ? () async {
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
