import 'package:flutter/material.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _weeklyPriceController = TextEditingController();
  final TextEditingController _monthlyPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  String selectedBrand = 'Toyota';
  String selectedClass = 'Económico';
  String selectedColor = 'Azul';
  String selectedFuelType = 'Eléctrico';
  String selectedTransmission = 'Automática';
  int selectedSeats = 5;
  bool hasInsurance = false;
  bool isAvailable = true;
  bool termsAccepted = false;

  final List<String> carBrands = [
    'Mazda',
    'BMW',
    'Mercedes',
    'Audi',
    'Honda',
    'Toyota',
    'Nissan',
    'Jeep',
    'VW',
    'Tesla',
    'Lamborghini',
  ];

  final List<String> carClasses = [
    'Económico',
    'Compacto',
    'Médio',
    'Executivo',
    'Luxo',
    'SUV',
    'Desportivo',
  ];

  final List<String> colors = [
    'Branco',
    'Cinzento',
    'Azul',
    'Preto',
    'Vermelho',
    'Prata',
  ];
  final List<String> fuelTypes = ['Eléctrico', 'Gasolina', 'Diesel', 'Híbrido'];
  final List<String> transmissions = ['Manual', 'Automática', 'CVT'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Koila',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar do proprietário
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Informações da Viatura
            Text(
              'Informações da Viatura',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 20),

            // ID da Viatura e ID do Proprietário
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _vehicleIdController,
                    hint: 'ID da Viatura',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _ownerIdController,
                    hint: 'ID do Proprietário',
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Marca e Modelo
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2F3E3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBrand,
                        dropdownColor: Color(0xFF2F3E3A),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        items: carBrands.map((brand) {
                          return DropdownMenuItem(
                            value: brand,
                            child: Text(
                              brand,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBrand = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _modelController,
                    hint: 'Modelo da Viatura',
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Ano e Classe
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _yearController,
                    hint: 'Ano',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: selectedClass,
                    items: carClasses,
                    hint: 'Classe',
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Preços
            Text(
              'Preços de Aluguer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _dailyPriceController,
                    hint: 'Diario',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _weeklyPriceController,
                    hint: 'Semanal',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _monthlyPriceController,
                    hint: 'Mensal',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Upload de imagens
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Text(
                    'Carregar imagens da viatura',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  Spacer(),
                  Icon(Icons.camera_alt, color: Colors.grey[400]),
                  SizedBox(width: 12),
                  Icon(Icons.image, color: Colors.grey[400]),
                  SizedBox(width: 12),
                  Icon(Icons.add_circle_outline, color: Colors.grey[400]),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Matrícula e Quilometragem
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _plateController,
                    hint: 'Número da Matrícula',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _mileageController,
                    hint: 'Quilometragem',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Cores
            Text(
              'Cor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((color) {
                Color colorValue = _getColorFromName(color);
                bool isSelected = selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Tipo de Combustível
            Text(
              'Tipo de Combustível',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 12),

            Row(
              children: fuelTypes.map((fuel) {
                bool isSelected = selectedFuelType == fuel;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFuelType = fuel;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF2F3E3A) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          fuel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Transmissão e Lugares
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: selectedTransmission,
                    items: transmissions,
                    hint: 'Transmissão',
                    onChanged: (value) {
                      setState(() {
                        selectedTransmission = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: selectedSeats.toString(),
                    items: ['2', '4', '5', '7', '8'],
                    hint: 'Lugares',
                    onChanged: (value) {
                      setState(() {
                        selectedSeats = int.parse(value!);
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Switches para Seguro e Disponibilidade
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: hasInsurance,
                        onChanged: (value) {
                          setState(() {
                            hasInsurance = value;
                          });
                        },
                        activeColor: Color(0xFF2F3E3A),
                      ),
                      Text('Tem Seguro'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            isAvailable = value;
                          });
                        },
                        activeColor: Color(0xFF2F3E3A),
                      ),
                      Text('Disponível'),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Descrição
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'Insira aqui a descrição...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Termos e condições
            Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      termsAccepted = value!;
                    });
                  },
                  activeColor: Color(0xFF2F3E3A),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        termsAccepted = !termsAccepted;
                      });
                    },
                    child: Text(
                      'Termos e continuar',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Botão Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: termsAccepted
                    ? () {
                        // Lógica de submissão
                        _submitVehicle();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2F3E3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Submeter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: TextStyle(color: Colors.black, fontSize: 16),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'Branco':
        return Colors.white;
      case 'Cinzento':
        return Colors.grey;
      case 'Azul':
        return Colors.blue;
      case 'Preto':
        return Colors.black;
      case 'Vermelho':
        return Colors.red;
      case 'Prata':
        return Colors.grey[400]!;
      default:
        return Colors.grey;
    }
  }

  void _submitVehicle() {
    // Aqui implementaria a lógica para enviar os dados
    Map<String, dynamic> vehicleData = {
      'id': _vehicleIdController.text,
      'ownerId': _ownerIdController.text,
      'brand': selectedBrand,
      'model': _modelController.text,
      'year': int.tryParse(_yearController.text) ?? 0,
      'dailyPrice': double.tryParse(_dailyPriceController.text) ?? 0.0,
      'weeklyPrice': double.tryParse(_weeklyPriceController.text) ?? 0.0,
      'monthlyPrice': double.tryParse(_monthlyPriceController.text) ?? 0.0,
      'class': selectedClass,
      'description': _descriptionController.text,
      'color': selectedColor,
      'fuelType': selectedFuelType,
      'mileage': int.tryParse(_mileageController.text) ?? 0,
      'seats': selectedSeats,
      'hasInsurance': hasInsurance,
      'isAvailable': isAvailable,
      'plate': _plateController.text,
      'transmission': selectedTransmission,
    };

    print('Dados da viatura: $vehicleData');

    // Mostrar confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viatura cadastrada com sucesso!'),
        backgroundColor: Color(0xFF2F3E3A),
      ),
    );
  }
}
