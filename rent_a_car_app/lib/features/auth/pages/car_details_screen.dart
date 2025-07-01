import 'package:flutter/material.dart';
import 'package:rent_a_car_app/models/car.dart';
import 'package:rent_a_car_app/models/review.dart';
import 'package:rent_a_car_app/widgets/car%20details/book_button.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_details_header.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_features_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_image_gallery.dart';
import 'package:rent_a_car_app/widgets/car%20details/car_info_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/dealer_section.dart';
import 'package:rent_a_car_app/widgets/car%20details/reviews_section.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool isFavorite = false;

  // Dados simulados para demonstração
  final List<Review> reviews = [
    Review(
      userName: 'Mauro',
      rating: 5.0,
      comment:
          'O aluguel do carro foi limpo, confiável, e o serviço foi rápido e eficiente. No geral, a experiência foi sem falhas e agradável.',
      timeAgo: 'Hoje',
      avatar: 'assets/avatars/jack.png',
    ),
    Review(
      userName: 'Gaol',
      rating: 4.0,
      comment:
          'O aluguel do carro foi limpo, confiável, e o serviço foi rápido e eficiente. No geral, a experiência foi sem falhas e agradável.',
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
              ? '${widget.car.name} adicionado aos favoritos!'
              : '${widget.car.name} removido dos favoritos!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isFavorite ? Colors.green : Colors.grey,
      ),
    );
  }

  void _bookNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carro: ${widget.car.name}'),
            Text(
              'Preço: ${widget.car.pricePerDay.toStringAsFixed(0)} meticais/dia',
            ),
            Text('Localização: ${widget.car.location}'),
            const SizedBox(height: 16),
            const Text('Deseja confirmar a reserva?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showBookingSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva do ${widget.car.name} confirmada!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _contactDealer() {
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
            const Text(
              'Entrar em Contato',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Ligar'),
              subtitle: const Text('+258 8283848586'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ligando para a concessionária...'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('WhatsApp'),
              subtitle: const Text('Enviar mensagem'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrindo WhatsApp...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: const Text('Email'),
              subtitle: const Text('contato@koila.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrindo email...')),
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
    // Simulando múltiplas imagens
    final images = [
      'assets/cars/${widget.car.imageUrl}',
      'assets/cars/${widget.car.imageUrl}',
      'assets/cars/${widget.car.imageUrl}',
    ];

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
                    DealerSection(onContact: _contactDealer),
                    CarFeaturesSection(car: widget.car),
                    ReviewsSection(reviews: reviews),
                    const SizedBox(height: 100), // Espaço para o botão fixo
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BookButton(onBookNow: _bookNow),
    );
  }
}
