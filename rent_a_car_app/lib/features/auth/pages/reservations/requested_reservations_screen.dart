import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:rent_a_car_app/features/cars/widgets/error_reservations_state.dart';
import 'package:rent_a_car_app/features/cars/widgets/requested_reservation_header.dart';
import 'package:rent_a_car_app/features/cars/widgets/requested_reservation_list_item.dart';
import 'package:rent_a_car_app/features/cars/widgets/requested_reservations_state.dart';

class RequestedReservationsScreen extends StatefulWidget {
  const RequestedReservationsScreen({super.key});

  @override
  State<RequestedReservationsScreen> createState() =>
      _RequestedReservationsScreenState();
}

class _RequestedReservationsScreenState
    extends State<RequestedReservationsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Reservation>> _futureReservations;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _futureReservations =
        ReservationService.getRequestedReservation(); // Novo método do service
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureReservations = ReservationService.getRequestedReservations();
    });
  }

  List<Reservation> _filterReservations(
    List<Reservation> reservations,
    String status,
  ) {
    if (status == 'all') return reservations;
    return reservations.where((r) => r.status == status).toList();
  }

  void _navigateToDetails(String reservationId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RequestedReservationDetailsScreen(reservationId: reservationId),
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
            RequestedReservationsHeader(onBack: () => Navigator.pop(context)),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReservationsList('all'),
                  _buildReservationsList('pending'),
                  _buildReservationsList('approved'),
                  _buildReservationsList('rejected'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
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
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.orange,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Pendentes'),
          Tab(text: 'Aprovadas'),
          Tab(text: 'Rejeitadas'),
        ],
      ),
    );
  }

  Widget _buildReservationsList(String filter) {
    return RefreshIndicator(
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

          final allReservations = snapshot.data ?? [];
          final filteredReservations = _filterReservations(
            allReservations,
            filter,
          );

          if (filteredReservations.isEmpty) {
            return EmptyRequestedReservationsState(filter: filter);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredReservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return RequestedReservationListItem(
                reservation: filteredReservations[index],
                onTap: () => _navigateToDetails(filteredReservations[index].id),
                onApprove: () =>
                    _approveReservation(filteredReservations[index].id),
                onReject: () =>
                    _rejectReservation(filteredReservations[index].id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveReservation(String reservationId) async {
    try {
      await ReservationService.approveReservation(reservationId);
      _showSuccessMessage('Reserva aprovada com sucesso!');
      _refresh();
    } catch (e) {
      _showErrorMessage('Erro ao aprovar reserva: $e');
    }
  }

  Future<void> _rejectReservation(String reservationId) async {
    try {
      await ReservationService.rejectReservation(reservationId);
      _showSuccessMessage('Reserva rejeitada.');
      _refresh();
    } catch (e) {
      _showErrorMessage('Erro ao rejeitar reserva: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
