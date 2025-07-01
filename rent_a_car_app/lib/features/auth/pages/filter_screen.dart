// screens/filters_screen.dart
import 'package:flutter/material.dart';

/// Tela de filtros para busca de carros
/// Permite filtrar por tipo, tempo de aluguel, data, localização, cores, capacidade e combustível
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  // Estado dos filtros
  String selectedCarType = 'Todos os Carros';
  String selectedRentalTime = 'Dia';
  DateTime? pickupDate;
  String selectedLocation = 'Rua Dr. Share, Chicago 60612 EUA';
  String selectedColor = 'Azul';
  int selectedSeatingCapacity = 4;
  String selectedFuelType = 'Elétrico';

  // Opções disponíveis
  final List<String> carTypes = [
    'Todos os Carros',
    'Carros Regulares',
    'Carros de Luxo',
  ];
  final List<String> rentalTimes = ['Dia', 'Semanal', 'Mensal'];
  final List<String> colors = ['Branco', 'Cinza', 'Azul', 'Preto'];
  final List<Color> colorValues = [
    Colors.white,
    Colors.grey,
    Colors.blue,
    Colors.black,
  ];
  final List<int> seatingCapacities = [2, 4, 6, 8];
  final List<String> fuelTypes = ['Elétrico', 'Gasolina', 'Diesel', 'Híbrido'];

  @override
  void initState() {
    super.initState();
    pickupDate = DateTime.now().add(const Duration(days: 1));
  }

  /// Seleciona data usando DatePicker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // REMOVIDO: locale: const Locale('pt', 'BR'), <- ESTA LINHA CAUSAVA O ERRO
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != pickupDate) {
      setState(() {
        pickupDate = picked;
      });
    }
  }

  /// Aplica os filtros e retorna para tela anterior
  void _applyFilters() {
    final filters = {
      'carType': selectedCarType,
      'rentalTime': selectedRentalTime,
      'pickupDate': pickupDate,
      'location': selectedLocation,
      'color': selectedColor,
      'seatingCapacity': selectedSeatingCapacity,
      'fuelType': selectedFuelType,
    };

    Navigator.pop(context, filters);
  }

  /// Limpa todos os filtros
  void _clearAllFilters() {
    setState(() {
      selectedCarType = 'Todos os Carros';
      selectedRentalTime = 'Dia';
      pickupDate = DateTime.now().add(const Duration(days: 1));
      selectedLocation = 'Rua Dr. Share, Chicago 60612 EUA';
      selectedColor = 'Azul';
      selectedSeatingCapacity = 4;
      selectedFuelType = 'Elétrico';
    });
  }

  /// Formata data para exibição
  String _formatDate(DateTime? date) {
    if (date == null) return 'Selecionar Data';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarTypeSection(),
                    const SizedBox(height: 24),
                    _buildRentalTimeSection(),
                    const SizedBox(height: 24),
                    _buildPickupDateSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildColorsSection(),
                    const SizedBox(height: 24),
                    _buildSeatingCapacitySection(),
                    const SizedBox(height: 24),
                    _buildFuelTypeSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  /// Constrói o cabeçalho da tela
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Filtros',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 36), // Para balancear o layout
        ],
      ),
    );
  }

  /// Constrói seção de tipo de carros
  Widget _buildCarTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Carros',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // CORRIGIDO: Voltou para Row para evitar problemas de overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: carTypes.map((type) {
              final isSelected = selectedCarType == type;
              return GestureDetector(
                onTap: () => setState(() => selectedCarType = type),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Constrói seção de tempo de aluguel
  Widget _buildRentalTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tempo de Aluguel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: rentalTimes.map((time) {
            final isSelected = selectedRentalTime == time;
            return GestureDetector(
              onTap: () => setState(() => selectedRentalTime = time),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Constrói seção de data de retirada
  Widget _buildPickupDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data de Retirada e Devolução',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(
                  _formatDate(pickupDate),
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói seção de localização
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização do Carro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedLocation,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói seção de cores
  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Ver Todas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(colors.length, (index) {
            final color = colors[index];
            final colorValue = colorValues[index];
            final isSelected = selectedColor == color;

            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: colorValue == Colors.white
                          ? Icon(
                              Icons.circle,
                              color: Colors.grey[300],
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      color,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Constrói seção de capacidade de assentos
  Widget _buildSeatingCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Capacidade de Assentos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: seatingCapacities.map((capacity) {
            final isSelected = selectedSeatingCapacity == capacity;
            return GestureDetector(
              onTap: () => setState(() => selectedSeatingCapacity = capacity),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    capacity.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Constrói seção de tipo de combustível
  Widget _buildFuelTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Combustível',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // CORRIGIDO: Wrap com melhor controle
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: fuelTypes.map((fuel) {
            final isSelected = selectedFuelType == fuel;
            return GestureDetector(
              onTap: () => setState(() => selectedFuelType = fuel),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fuel,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Constrói ações da parte inferior
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: _clearAllFilters,
              child: const Text(
                'Limpar Tudo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mostrar 100+ Carros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
