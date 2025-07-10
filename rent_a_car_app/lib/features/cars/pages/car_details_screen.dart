import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rent_a_car_app/features/auth/pages/dealer/dealer_details_screen.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/location_section.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/services_section.dart';
import 'package:rent_a_car_app/models/dealer.dart';
import 'package:rent_a_car_app/models/review.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/book_button.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/car_details_header.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/car_features_section.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/car_image_gallery.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/car_info_section.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/dealer_section.dart';
import 'package:rent_a_car_app/features/cars/widgets/car%20details/reviews_section.dart';
import 'package:rent_a_car_app/core/services/reservation_service.dart';
import 'package:intl/intl.dart';

import '../../../core/models/car_model.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';

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
      comment:
          'O aluguel do carro foi limpo, confiável, e o serviço foi rápido e eficiente.',
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
          SnackBar(
            content: Text('Erro ao reservar: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _navigateToDealerDetails() {
    final owner = widget.car.owner;

    if (owner != null) {
      final dealer = Dealer(
        id: owner.id?.toString() ?? '1',
        name: '${owner.name} ${owner.lastName ?? ''}',
        location: owner.address ?? 'Maputo, Moçambique',
        phone: owner.telephone ?? '+258 84 123 4567',
        profileImage: null, // ou owner.profileImage se existir
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DealerDetailsScreen(dealer: dealer),
        ),
      );
    }
  }

  /*void _contactDealer() {
    _navigateToDealerDetails();
  }*/

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
                      DealerSection(onContact: () {}, owner: widget.car.owner!),

                    // adição de location e services
                    LocationSection(car: widget.car),
                    ServicesSection(car: widget.car),

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
    if (url.startsWith('http')) {
      // Se já for uma URL absoluta, só faz o replace se for localhost
      return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
    } else {
      // Se for um path relativo, monta com baseUrl
      return '$baseUrl/$url';
    }
  }
}

// ===========================
// 📁 Modificação no CarDetailsScreen - Dialog Melhorado
// ===========================

// Substitua as classes _ReservationDialog e _ReservationDialogResult por estas:

class _ReservationDialogResult {
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  _ReservationDialogResult({
    required this.startDate,
    required this.endDate,
    this.notes,
  });
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

    if (!isStart && _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data de início primeiro'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate!.add(const Duration(days: 1)));
    final firstDate = isStart ? now : _startDate!.add(const Duration(days: 1));

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
          if (_endDate != null &&
              _endDate!.isBefore(_startDate!.add(const Duration(days: 1)))) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  double _calculatePrice() {
    if (_startDate == null || _endDate == null) return 0;

    return ReservationService.calculateReservationPrice(
      startDate: _startDate!,
      endDate: _endDate!,
      dailyPrice: widget.car.precoPorDia,
      weeklyPrice: widget.car.precoPorSemana,
      monthlyPrice: widget.car.precoPorMes,
    );
  }

  String _formatPeriod() {
    if (_startDate == null || _endDate == null) return '';

    return ReservationService.formatReservationPeriod(
      startDate: _startDate!,
      endDate: _endDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculatePrice();
    final period = _formatPeriod();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reservar Veículo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car Info
                      _buildCarSummary(),
                      const SizedBox(height: 20),

                      // Date Selection
                      _buildDateSection(),
                      const SizedBox(height: 20),

                      // Price Breakdown
                      if (_startDate != null && _endDate != null) ...[
                        _buildPriceSection(totalPrice, period),
                        const SizedBox(height: 20),
                      ],

                      // Notes
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(totalPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.car.marca} ${widget.car.modelo}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.car.ano} • ${widget.car.cor}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Período da Reserva',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: 'Início',
                date: _startDate,
                onTap: () => _pickDate(isStart: true),
                icon: Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateSelector(
                label: 'Fim',
                date: _endDate,
                onTap: () => _pickDate(isStart: false),
                icon: Icons.event,
                enabled: _startDate != null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: enabled ? Colors.black : Colors.grey[400],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled ? Colors.grey[600] : Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Selecionar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.black : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(double totalPrice, String period) {
    final days = _endDate!.difference(_startDate!).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                'Resumo do Preço',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Período:', period),
          _buildPriceRow(
            'Preço por dia:',
            'MT ${widget.car.precoPorDia.toStringAsFixed(0)}',
          ),
          _buildPriceRow(
            '$days ${days == 1 ? 'dia' : 'dias'}:',
            'MT ${totalPrice.toStringAsFixed(0)}',
          ),
          const Divider(height: 16),
          _buildPriceRow(
            'Total:',
            'MT ${totalPrice.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 12,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green[700] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observações (opcional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Adicione observações sobre sua reserva...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(double totalPrice) {
    final canReserve = _formKey.currentState?.validate() ?? false;
    final hasValidDates = _startDate != null && _endDate != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          if (totalPrice > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total da Reserva:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'MT ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: hasValidDates
                      ? () {
                          Navigator.pop(
                            context,
                            _ReservationDialogResult(
                              startDate: _startDate!,
                              endDate: _endDate!,
                              notes: _notesController.text.isNotEmpty
                                  ? _notesController.text
                                  : null,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirmar Reserva',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
