import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/Owner_Image_upload_service.dart';
import 'package:rent_a_car_app/core/services/owner_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rent_a_car_app/core/models/car_model.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final ApiCar? car;
  const VehicleRegistrationScreen({super.key, this.car});

  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _weeklyPriceController = TextEditingController();
  final TextEditingController _monthlyPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

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
    'Mazda', 'BMW', 'Mercedes', 'Audi', 'Honda', 'Toyota', 
    'Nissan', 'Jeep', 'VW', 'Tesla', 'Lamborghini',
  ];
  final List<String> carClasses = [
    'Económico', 'Compacto', 'Médio', 'Executivo', 'Luxo', 'SUV', 'Desportivo',
  ];
  final List<String> colors = [
    'Branco', 'Cinzento', 'Azul', 'Preto', 'Vermelho', 'Prata',
  ];
  final List<String> fuelTypes = ['Eléctrico', 'Gasolina', 'Diesel', 'Híbrido'];
  final List<String> transmissions = ['Manual', 'Automática', 'CVT'];

  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      // Preencher campos com dados do carro
      selectedBrand = carBrands.firstWhere(
        (b) => b.toLowerCase() == widget.car!.marca.toLowerCase(),
        orElse: () => carBrands.first,
      );
      _modelController.text = widget.car!.modelo;
      _yearController.text = widget.car!.ano.toString();
      _dailyPriceController.text = widget.car!.precoPorDia.toString();
      _weeklyPriceController.text = widget.car!.precoPorSemana.toString();
      _monthlyPriceController.text = widget.car!.precoPorMes.toString();
      selectedClass = carClasses.firstWhere(
        (c) => c.toLowerCase() == widget.car!.classe.toLowerCase(),
        orElse: () => carClasses.first,
      );
      _descriptionController.text = widget.car!.descricao;
      // Cor
      selectedColor = colors.firstWhere(
        (c) => c.toLowerCase() == widget.car!.cor.toLowerCase(),
        orElse: () => widget.car!.cor,
      );
      // Combustível
      selectedFuelType = fuelTypes.firstWhere(
        (f) => f.toLowerCase() == widget.car!.combustivel.toLowerCase(),
        orElse: () => widget.car!.combustivel,
      );
      _mileageController.text = widget.car!.quilometragem.toString();
      selectedSeats = widget.car!.lugares;
      selectedTransmission = transmissions.firstWhere(
        (t) => t.toLowerCase() == widget.car!.transmissao.toString().toLowerCase(),
        orElse: () => transmissions.first,
      );
      isAvailable = widget.car!.disponibilidade;
      hasInsurance = widget.car!.seguro == 'true' || widget.car!.seguro == true;
      _plateController.text = widget.car!.placa;
      _localizacaoController.text = widget.car!.localizacao;
      _serviceType = _serviceTypes.firstWhere(
        (s) => s.toLowerCase() == widget.car!.serviceType.toLowerCase(),
        orElse: () => _serviceTypes.first,
      );
      _categoryController.text = widget.car!.categorias ?? '';
      // Imagens existentes
      if (widget.car!.images.isNotEmpty) {
        _existingImageUrls = List<String>.from(widget.car!.images);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Adicionar Veículo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Imagens
              _buildImageSection(),
              SizedBox(height: 24),
              
              // Informações Básicas
              _buildSectionCard(
                title: 'Informações Básicas',
                children: [
                  _buildBrandModelRow(),
                  SizedBox(height: 16),
                  _buildYearClassRow(),
                  SizedBox(height: 16),
                  _buildPlateLocationRow(),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Especificações
              _buildSectionCard(
                title: 'Especificações',
                children: [
                  _buildColorSelector(),
                  SizedBox(height: 20),
                  _buildFuelTypeSelector(),
                  SizedBox(height: 20),
                  _buildTransmissionSeatsRow(),
                  SizedBox(height: 16),
                  _buildMileageField(),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Preços
              _buildSectionCard(
                title: 'Preços de Aluguer',
                children: [
                  _buildPriceRow(),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Configurações
              _buildSectionCard(
                title: 'Configurações',
                children: [
                  _buildServiceTypeField(),
                  SizedBox(height: 16),
                  _buildSwitchesRow(),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Descrição
              _buildSectionCard(
                title: 'Descrição',
                children: [
                  _buildDescriptionField(),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Termos e Botão
              _buildTermsAndSubmit(),
              
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Fotos do Veículo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.add_photo_alternate, color: Color(0xFF2F3E3A)),
                onPressed: _pickImages,
              ),
            ],
          ),
          SizedBox(height: 16),
          (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              ? Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                        SizedBox(height: 8),
                        Text(
                          'Adicionar fotos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImageUrls.length + _selectedImages.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index < _existingImageUrls.length) {
                        // Imagem existente (URL)
                        final url = _existingImageUrls[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _existingImageUrls.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Imagem nova (XFile)
                        final imgIndex = index - _existingImageUrls.length;
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImageWidget(_selectedImages[imgIndex]),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(imgIndex);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Widget para exibir imagem compatível com web e mobile
  Widget _buildImageWidget(XFile imageFile) {
    if (kIsWeb) {
      return Image.network(
        imageFile.path,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } else {
      return Image.file(
        File(imageFile.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }

  Widget _buildBrandModelRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            value: selectedBrand,
            items: carBrands,
            hint: 'Marca',
            onChanged: (value) {
              setState(() {
                selectedBrand = value!;
              });
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _modelController,
            hint: 'Modelo',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insira o modelo';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearClassRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _yearController,
            hint: 'Ano',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insira o ano';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildDropdownField(
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
    );
  }

  Widget _buildPlateLocationRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _plateController,
            hint: 'Matrícula',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insira a matrícula';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _localizacaoController,
            hint: 'Localização',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Insira a localização';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cor',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Color(0xFF2F3E3A) : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFuelTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Combustível',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
                  margin: EdgeInsets.only(right: fuel == fuelTypes.last ? 0 : 8),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF2F3E3A) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Color(0xFF2F3E3A) : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      fuel,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
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

  Widget _buildTransmissionSeatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
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
          child: _buildDropdownField(
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
    );
  }

  Widget _buildMileageField() {
    return _buildTextField(
      controller: _mileageController,
      hint: 'Quilometragem',
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira a quilometragem';
        }
        return null;
      },
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _dailyPriceController,
            hint: 'Diário',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Preço obrigatório';
              }
              return null;
            },
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
    );
  }

  Widget _buildServiceTypeField() {
    return _buildDropdownField(
      value: _serviceType.isNotEmpty ? _serviceType : null,
      items: _serviceTypes,
      hint: 'Tipo de Serviço',
      onChanged: (value) {
        setState(() {
          _serviceType = value!;
        });
      },
    );
  }

  Widget _buildSwitchesRow() {
    return Row(
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
              Text('Tem Seguro', style: TextStyle(fontSize: 14)),
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
              Text('Disponível', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        maxLength: 1000,
        decoration: InputDecoration(
          hintText: 'Descrição do veículo...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTermsAndSubmit() {
    return Column(
      children: [
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
                  'Aceito os termos e condições',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: termsAccepted && !_isLoading ? _submitVehicle : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2F3E3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Adicionar Veículo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey[500])),
          style: TextStyle(color: Colors.black87, fontSize: 16),
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
    try {
      if (kIsWeb) {
        // Para web, use pickMultiImage
        final List<XFile>? picked = await _picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (picked != null && picked.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(picked);
          });
        }
      } else {
        // Para mobile, use pickMultiImage também
        final List<XFile>? picked = await _picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        if (picked != null && picked.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(picked);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagens: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_serviceType.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione o tipo de serviço.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Validar imagens antes do upload
    if (_selectedImages.isNotEmpty) {
      List<XFile> validImages = [];
      for (XFile image in _selectedImages) {
        if (await ImageUploadService.validateImage(image)) {
          validImages.add(image);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Algumas imagens são muito grandes ou formato inválido'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      _selectedImages = validImages;
    }
    Map<String, dynamic> vehicleData = {
      'marca': selectedBrand,
      'modelo': _modelController.text.trim(),
      'ano': int.tryParse(_yearController.text) ?? 0,
      'precoPorDia': double.tryParse(_dailyPriceController.text) ?? 0.0,
      'precoPorSemana': double.tryParse(_weeklyPriceController.text) ?? 0.0,
      'precoPorMes': double.tryParse(_monthlyPriceController.text) ?? 0.0,
      'classe': selectedClass,
      'descricao': _descriptionController.text.trim(),
      'cor': selectedColor,
      'combustivel': selectedFuelType,
      'quilometragem': int.tryParse(_mileageController.text) ?? 0,
      'lugares': selectedSeats,
      'transmissao': selectedTransmission,
      'disponibilidade': isAvailable,
      'seguro': hasInsurance,
      'placa': _plateController.text.trim(),
      'localizacao': _localizacaoController.text.trim(),
      'categorias': _categoryController.text.trim(),
      'featured': false,
      'serviceType': _serviceType,
      'existingImages': _existingImageUrls, // Envie as imagens mantidas
    };
    try {
      if (widget.car != null) {
        // PATCH para atualizar carro existente
        await OwnerServiceImageUpload.updateCarWithImages(
          widget.car!.id,
          vehicleData,
          _selectedImages,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Veículo atualizado com sucesso!'),
              backgroundColor: Color(0xFF2F3E3A),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Criação normal
        final result = await OwnerServiceImageUpload.createCarWithImages(
          vehicleData,
          _selectedImages,
        );
        if (mounted) {
          String message = 'Veículo cadastrado com sucesso!';
          if (_selectedImages.isNotEmpty) {
            message += ' ${result['uploaded_images']}/${result['total_images']} imagens enviadas.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Color(0xFF2F3E3A),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar/atualizar veículo: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _dailyPriceController.dispose();
    _weeklyPriceController.dispose();
    _monthlyPriceController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _plateController.dispose();
    _localizacaoController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}