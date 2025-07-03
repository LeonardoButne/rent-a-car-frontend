import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CarImageGallery extends StatefulWidget {
  final List<String> images;

  const CarImageGallery({super.key, required this.images});

  @override
  State<CarImageGallery> createState() => _CarImageGalleryState();
}

class _CarImageGalleryState extends State<CarImageGallery> {
  PageController pageController = PageController();
  int currentImageIndex = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imageUrl = widget.images[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    fixImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentImageIndex == entry.key ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentImageIndex == entry.key
                        ? Colors.black
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

String fixImageUrl(String url) {
  if (url.startsWith('http')) {
    return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
  } else {
    return '$baseUrl/$url';
  }
}
