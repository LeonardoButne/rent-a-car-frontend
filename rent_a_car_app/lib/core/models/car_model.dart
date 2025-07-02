// models/car_models.dart

// Modelo de dados para o proprietário do carro
class CarOwner {
  final String id;
  final String name;
  final String lastName;
  final String telephone;
  final String email;
  final String? address;
  final String? subscriptionPackage;
  final bool isSuspended;

  CarOwner({
    required this.id,
    required this.name,
    required this.lastName,
    required this.telephone,
    required this.email,
    this.address,
    this.subscriptionPackage,
    required this.isSuspended,
  });

  factory CarOwner.fromJson(Map<String, dynamic> json) {
    return CarOwner(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      telephone: json['telephone'],
      email: json['email'],
      address: json['address'],
      subscriptionPackage: json['subscriptionPackage'],
      isSuspended: json['isSuspended'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'telephone': telephone,
      'email': email,
      'address': address,
      'subscriptionPackage': subscriptionPackage,
      'isSuspended': isSuspended,
    };
  }
}

// Modelo de dados para as imagens do carro
class CarImage {
  final String url;
  final String id;
  final String fileName;
  final String originalName;

  CarImage({
    required this.url,
    required this.id,
    required this.fileName,
    required this.originalName,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      url: json['url'],
      id: json['id'],
      fileName: json['fileName'],
      originalName: json['originalName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'id': id,
      'fileName': fileName,
      'originalName': originalName,
    };
  }
}

// Modelo de dados principal do carro
class ApiCar {
  final String id;
  final String ownerId;
  final String marca;
  final String modelo;
  final int ano;
  final double precoPorDia;
  final double precoPorSemana;
  final double precoPorMes;
  final String classe;
  final String categorias;
  final String descricao;
  final String cor;
  final String combustivel;
  final int quilometragem;
  final int lugares;
  final String transmissao;
  final bool featured;
  final bool disponibilidade;
  final String localizacao;
  final String seguro;
  final String placa;
  final String serviceType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<String> images;
  final CarOwner? owner;

  ApiCar({
    required this.id,
    required this.ownerId,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.precoPorDia,
    required this.precoPorSemana,
    required this.precoPorMes,
    required this.classe,
    required this.categorias,
    required this.descricao,
    required this.cor,
    required this.combustivel,
    required this.quilometragem,
    required this.lugares,
    required this.transmissao,
    required this.featured,
    required this.disponibilidade,
    required this.localizacao,
    required this.seguro,
    required this.placa,
    required this.serviceType,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.images,
    this.owner,
  });

  factory ApiCar.fromJson(Map<String, dynamic> json) {
    return ApiCar(
      id: json['id'],
      ownerId: json['ownerId'],
      marca: json['marca'],
      modelo: json['modelo'],
      ano: json['ano'],
      precoPorDia: json['precoPorDia'].toDouble(),
      precoPorSemana: json['precoPorSemana'].toDouble(),
      precoPorMes: json['precoPorMes'].toDouble(),
      classe: json['classe'],
      categorias: json['categorias'],
      descricao: json['descricao'],
      cor: json['cor'],
      combustivel: json['combustivel'],
      quilometragem: json['quilometragem'],
      lugares: json['lugares'],
      transmissao: json['transmissao'],
      featured: json['featured'],
      disponibilidade: json['disponibilidade'],
      localizacao: json['localizacao'],
      seguro: json['seguro'],
      placa: json['placa'],
      serviceType: json['serviceType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      images: (json['images'] as List?)?.map((img) => img['url'] as String).toList() ?? [],
      owner: json['owner'] != null ? CarOwner.fromJson(json['owner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'precoPorDia': precoPorDia,
      'precoPorSemana': precoPorSemana,
      'precoPorMes': precoPorMes,
      'classe': classe,
      'categorias': categorias,
      'descricao': descricao,
      'cor': cor,
      'combustivel': combustivel,
      'quilometragem': quilometragem,
      'lugares': lugares,
      'transmissao': transmissao,
      'featured': featured,
      'disponibilidade': disponibilidade,
      'localizacao': localizacao,
      'seguro': seguro,
      'placa': placa,
      'serviceType': serviceType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'images': images,
      'owner': owner?.toJson(),
    };
  }

  // Métodos utilitários que podem ser úteis
  String get fullName => '$marca $modelo';

  String get yearAndColor => '$ano • $cor';

  String get pricePerDayFormatted => 'MT ${precoPorDia.toStringAsFixed(0)}/dia';

  String get firstImageUrl => images.isNotEmpty ? images.first : '';

  bool get hasImages => images.isNotEmpty;

  // Método para obter URL da imagem corrigida (para emulador Android)
  String getFixedImageUrl(String url) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }

  String get firstImageUrlFixed => hasImages ? getFixedImageUrl(firstImageUrl) : '';
}