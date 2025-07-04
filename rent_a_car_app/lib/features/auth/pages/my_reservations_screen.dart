import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:rent_a_car_app/features/auth/pages/reservations/reservation_details_screen.dart';
import 'package:rent_a_car_app/features/cars/widgets/empty_reservation_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/error_reservations_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/reservation_list_item.dart';
import 'package:rent_a_car_app/features/cars/widgets/reservations_header.dart';

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

  void _navigateToDetails(String reservationId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReservationDetailsScreen(reservationId: reservationId),
      ),
    );
    if (result == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            ReservationsHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Reservation>>(
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
                      return const EmptyReservationsState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: reservations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return ReservationListItem(
                          reservation: reservations[index],
                          onTap: () =>
                              _navigateToDetails(reservations[index].id),
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
