import 'package:flutter/material.dart';
import 'package:rent_a_car_app/models/review.dart';
import 'package:rent_a_car_app/widgets/car%20details/review_item.dart';

class ReviewsSection extends StatelessWidget {
  final List<Review> reviews;

  const ReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Avaliação (125)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Ver Todas',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.take(2).map((review) => ReviewItem(review: review)),
        ],
      ),
    );
  }
}
