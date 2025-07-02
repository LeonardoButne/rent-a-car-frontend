import 'package:flutter/material.dart';
import 'package:rent_a_car_app/models/review.dart';
import 'package:rent_a_car_app/widgets/car%20details/book_button.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_details_header.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_features_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_image_gallery.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_info_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/dealer_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/reviews_section.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:intl/intl.dart';

import '../../../core/models/car_model.dart';

class CarDetailsScreen extends StatefulWidget {
  final ApiCar car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool isFavorite = false;

  final List<Review> reviews = [
    Review(
      userName: 'Mauro',
      rating: 5.0,
      comment: 'O aluguel do carro foi limpo, confiável, e o serviço foi rápido e eficiente.',
      timeAgo: 'Hoje',
      avatar: 'assets/avatars/jack.png',
    ),
    Review(
      userName: 'Gaol',
      rating: 4.0,
      comment: 'Boa experiência, mas o carro estava com pouco combustível.',
      timeAgo: 'Ontem',
      avatar: 'assets/avatars/robert.png',
    ),
  ];

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${widget.car.modelo} adicionado aos favoritos!'
              : '${widget.car.modelo} removido dos favoritos!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isFavorite ? Colors.green : Colors.grey,
      ),
    );
  }

  void _bookNow() async {
    final result = await showDialog<_ReservationDialogResult>(
      context: context,
      builder: (context) => _ReservationDialog(car: widget.car),
    );
    if (result != null) {
      try {
        final reservation = await ReservationService.createReservation(
          carId: widget.car.id,
          ownerId: widget.car.ownerId,
          startDate: result.startDate,
          endDate: result.endDate,
          notes: result.notes,
        );
        _showBookingSuccess(reservation);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reservar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showBookingSuccess(reservation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva criada com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _contactDealer() {
    final owner = widget.car.owner;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrar em Contato com ${owner?.name ?? "Proprietário"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (owner != null) ...[
              const SizedBox(height: 10),
              Text(
                '${owner.name} ${owner.lastName}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                owner.address ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 20),
            if (owner?.telephone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Ligar'),
                subtitle: Text(owner!.telephone),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ligando para ${owner.telephone}...'),
                    ),
                  );
                },
              ),
            if (owner?.telephone != null)
              ListTile(
                leading: const Icon(Icons.message, color: Colors.blue),
                title: const Text('WhatsApp'),
                subtitle: Text('Enviar mensagem para ${owner!.telephone}'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrindo WhatsApp...')),
                  );
                },
              ),
            if (owner?.email != null)
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: const Text('Email'),
                subtitle: Text(owner!.email),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Enviando email para ${owner.email}...')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.car.images.map(fixImageUrl).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CarDetailsHeader(
              isFavorite: isFavorite,
              onFavoriteToggle: _toggleFavorite,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CarImageGallery(images: images),
                    CarInfoSection(car: widget.car),
                    if (widget.car.owner != null)
                      DealerSection(
                        onContact: _contactDealer,
                        owner: widget.car.owner!,
                      ),
                    CarFeaturesSection(car: widget.car),
                    ReviewsSection(reviews: reviews),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            BookButton(onBookNow: _bookNow),
          ],
        ),
      ),
    );
  }

  String fixImageUrl(String url) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }
}

class _ReservationDialogResult {
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  _ReservationDialogResult({required this.startDate, required this.endDate, this.notes});
}

class _ReservationDialog extends StatefulWidget {
  final ApiCar car;
  const _ReservationDialog({super.key, required this.car});
  @override
  State<_ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<_ReservationDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart ? (_startDate ?? now) : (_endDate ?? now.add(const Duration(days: 1)));
    final firstDate = isStart ? now : (_startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reservar Carro'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(isStart: true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Data Início'),
                        controller: TextEditingController(
                          text: _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : '',
                        ),
                        validator: (_) => _startDate == null ? 'Selecione a data' : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(isStart: false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Data Fim'),
                        controller: TextEditingController(
                          text: _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : '',
                        ),
                        validator: (_) => _endDate == null ? 'Selecione a data' : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Observação (opcional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                _ReservationDialogResult(
                  startDate: _startDate!,
                  endDate: _endDate!,
                  notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                ),
              );
            }
          },
          child: const Text('Reservar'),
        ),
      ],
    );
  }
}
