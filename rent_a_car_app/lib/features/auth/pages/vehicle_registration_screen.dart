import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/owner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

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
  final TextEditingController _localizacaoController = TextEditingController();

  String selectedBrand = 'Toyota';
  String selectedClass = 'Económico';
  String selectedColor = 'Azul';
  String selectedFuelType = 'Eléctrico';
  String selectedTransmission = 'Automática';
  int selectedSeats = 5;
  bool hasInsurance = false;
  bool isAvailable = true;
  bool termsAccepted = false;
  bool _isLoading = false;
  String _serviceType = '';
  final List<String> _serviceTypes = ['Logística', 'Aluguer'];

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

  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Carregar imagens da viatura',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add_a_photo, color: Colors.blue),
                        onPressed: _pickImages,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _selectedImages.isEmpty
                      ? Text('Nenhuma imagem selecionada', style: TextStyle(color: Colors.grey[400]))
                      : SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            separatorBuilder: (_, __) => SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
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

            SizedBox(height: 16),
            // Campo Localização
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _localizacaoController,
                decoration: InputDecoration(
                  hintText: 'Localização',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
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

            // Tipo de Serviço
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _serviceType.isNotEmpty ? _serviceType : null,
              items: _serviceTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _serviceType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tipo de Serviço',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione o tipo de serviço';
                }
                return null;
              },
            ),

            // Botão Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: termsAccepted && !_isLoading
                    ? _submitVehicle
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

            if (_isLoading) ...[
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()),
            ],

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

  Future<void> _pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked);
      });
    }
  }

  void _submitVehicle() async {
    setState(() { _isLoading = true; });
    if (_localizacaoController.text.trim().isEmpty) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe a localização do carro.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_serviceType.isEmpty) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione o tipo de serviço.'), backgroundColor: Colors.red),
      );
      return;
    }
    Map<String, dynamic> vehicleData = {
      'marca': selectedBrand,
      'modelo': _modelController.text,
      'ano': int.tryParse(_yearController.text) ?? 0,
      'precoPorDia': double.tryParse(_dailyPriceController.text) ?? 0.0,
      'precoPorSemana': double.tryParse(_weeklyPriceController.text) ?? 0.0,
      'precoPorMes': double.tryParse(_monthlyPriceController.text) ?? 0.0,
      'classe': selectedClass,
      'descricao': _descriptionController.text,
      'cor': selectedColor,
      'combustivel': selectedFuelType,
      'quilometragem': int.tryParse(_mileageController.text) ?? 0,
      'lugares': selectedSeats,
      'transmissao': selectedTransmission,
      'disponibilidade': isAvailable,
      'seguro': hasInsurance,
      'placa': _plateController.text,
      'localizacao': _localizacaoController.text.trim(),
      'categorias': '',
      'featured': false,
      'serviceType': _serviceType,
    };
    try {
      final car = await OwnerService.createCar(
        vehicleData,
        _selectedImages.map((xfile) => File(xfile.path)).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viatura cadastrada com sucesso!'),
            backgroundColor: Color(0xFF2F3E3A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar viatura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _ownerIdController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _dailyPriceController.dispose();
    _weeklyPriceController.dispose();
    _monthlyPriceController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _plateController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }
}
