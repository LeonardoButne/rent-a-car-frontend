import 'package:flutter/material.dart';
import '../models/brand.dart';

/// seleção de marcas de carros
class BrandSelector extends StatelessWidget {
  final List<Brand> brands;
  final String? selectedBrand;
  final Function(String) onBrandSelected;

  const BrandSelector({
    super.key,
    required this.brands,
    this.selectedBrand,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: brands.map((brand) => _buildBrandItem(brand)).toList(),
      ),
    );
  }

  ///item individual de marca
  Widget _buildBrandItem(Brand brand) {
    final isSelected = selectedBrand == brand.slug;

    return GestureDetector(
      onTap: () => onBrandSelected(brand.slug),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                brand.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 24);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brand.name,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
