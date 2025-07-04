import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/models/reservation.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:rent_a_car_app/features/cars/widgets/cancel_button.dart';
import 'package:rent_a_car_app/features/cars/widgets/car_info_card.dart';
import 'package:rent_a_car_app/features/cars/widgets/notes_card.dart';
import 'package:rent_a_car_app/features/cars/widgets/owner_info_card.dart';
import 'package:rent_a_car_app/features/cars/widgets/reservation_detail_header.dart';
import 'package:rent_a_car_app/features/cars/widgets/reservation_info_card.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final String reservationId;

  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late Future<Reservation> _futureReservation;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _futureReservation = ReservationService.getReservationById(
      widget.reservationId,
    );
  }

  Future<void> _cancelReservation() async {
    final shouldCancel = await _showCancelConfirmation();
    if (!shouldCancel) return;

    setState(() {
      _isCancelling = true;
    });
    try {
      await ReservationService.cancelReservation(widget.reservationId);
      if (mounted) {
        _showSuccessMessage('Reserva cancelada com sucesso');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isCancelling = false;
      });
      _showErrorMessage('Erro ao cancelar: $e');
    }
  }

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancelar Reserva'),
            content: const Text(
              'Tem certeza que deseja cancelar esta reserva?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sim, Cancelar'),
              ),
            ],
          ),
        ) ??
        false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FutureBuilder<Reservation>(
          future: _futureReservation,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final reservation = snapshot.data!;
            final canCancel = [
              'pending',
              'approved',
            ].contains(reservation.status);

            return Column(
              children: [
                ReservationDetailsHeader(
                  reservation: reservation,
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CarInfoCard(reservation: reservation),
                        const SizedBox(height: 16),
                        ReservationInfoCard(reservation: reservation),
                        const SizedBox(height: 16),
                        OwnerInfoCard(reservation: reservation),
                        if (reservation.notes?.isNotEmpty == true) ...[
                          const SizedBox(height: 16),
                          NotesCard(notes: reservation.notes!),
                        ],
                      ],
                    ),
                  ),
                ),
                if (canCancel)
                  CancelButton(
                    isCancelling: _isCancelling,
                    onCancel: _cancelReservation,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
