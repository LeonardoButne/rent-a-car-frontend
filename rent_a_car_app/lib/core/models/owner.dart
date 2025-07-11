class Owner {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String telephone;
  final String address;
  final String? subscriptionPackage;
  final bool statusAccount;
  Owner({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.address,
    this.subscriptionPackage,
    required this.statusAccount,
  });
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      telephone: json['telephone'],
      address: json['address'],
      subscriptionPackage: json['subscriptionPackage'],
      statusAccount: json['statusAccount'] ?? false,
    );
  }
}

class OwnerCar {
  final String id;
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
  final List<CarImage> images;
  OwnerCar({
    required this.id,
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
    required this.images,
  });
  factory OwnerCar.fromJson(Map<String, dynamic> json) {
    return OwnerCar(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      ano: json['ano'],
      precoPorDia: (json['precoPorDia'] as num).toDouble(),
      precoPorSemana: (json['precoPorSemana'] as num).toDouble(),
      precoPorMes: (json['precoPorMes'] as num).toDouble(),
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
      images: (json['images'] as List?)?.map((img) => CarImage.fromJson(img)).toList() ?? [],
    );
  }
}

class OwnerClient {
  final String id;
  final String name;
  final String email;
  OwnerClient({required this.id, required this.name, required this.email});
  factory OwnerClient.fromJson(Map<String, dynamic> json) {
    return OwnerClient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class OwnerReservation {
  final String id;
  final OwnerCar? car;
  final OwnerClient? client;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double price;
  final String? notes;
  OwnerReservation({
    required this.id,
    required this.car,
    required this.client,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.price,
    this.notes,
  });
  factory OwnerReservation.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    return OwnerReservation(
      id: json['id'],
      car: json['car'] != null ? OwnerCar.fromJson(json['car']) : null,
      client: json['client'] != null ? OwnerClient.fromJson(json['client']) : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      price: parsePrice(json['price']),
      notes: json['notes'],
    );
  }
}

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
} 