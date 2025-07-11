import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rent_a_car_app/core/services/api_service.dart';
import 'package:rent_a_car_app/core/services/owner_service.dart';
import 'dart:convert';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ImageUploadService {
  // Usar sua URL base real
  
  /// Upload de múltiplas imagens junto com dados do veículo
  static Future<Map<String, dynamic>> createVehicleWithImages(
    Map<String, dynamic> vehicleData,
    List<XFile> imageFiles,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}/owner/create/car'),
      );
      
      // Adicionar headers de autenticação
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Adicionar dados do veículo
      vehicleData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      // Adicionar imagens
      for (int i = 0; i < imageFiles.length; i++) {
        http.MultipartFile multipartFile;
        // Detectar mimetype pelo nome do arquivo
        String fileName = kIsWeb ? imageFiles[i].name : imageFiles[i].path;
        String mime = '';
        if (fileName.toLowerCase().endsWith('.png')) {
          mime = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
          mime = 'image/jpeg';
        } else if (fileName.toLowerCase().endsWith('.webp')) {
          mime = 'image/webp';
        } else if (fileName.toLowerCase().endsWith('.gif')) {
          mime = 'image/gif';
        } else if (fileName.toLowerCase().endsWith('.bmp')) {
          mime = 'image/bmp';
        } else if (fileName.toLowerCase().endsWith('.tiff')) {
          mime = 'image/tiff';
        } else {
          mime = 'image/jpeg'; // fallback
        }
        if (kIsWeb) {
          Uint8List bytes = await imageFiles[i].readAsBytes();
          multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: 'vehicle_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        } else {
          multipartFile = await http.MultipartFile.fromPath(
            'images',
            imageFiles[i].path,
            filename: 'vehicle_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        }
        request.files.add(multipartFile);
      }
      
      // Enviar requisição
      var response = await request.send();
      
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        
        return {
          'success': true,
          'vehicle': jsonResponse['vehicle'],
          'uploaded_images': jsonResponse['uploaded_images'],
          'total_images': jsonResponse['total_images'],
        };
      } else {
        var errorData = await response.stream.bytesToString();
        throw Exception('Erro no servidor: ${response.statusCode} - $errorData');
      }
    } catch (e) {
      throw Exception('Erro ao criar veículo: $e');
    }
  }
  
  /// Upload adicional de imagens para veículo existente
  static Future<List<String>> uploadAdditionalImages(
    List<XFile> imageFiles,
    String vehicleId,
  ) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${baseUrl}/owner/car/$vehicleId/images'),
      );
      
      // Adicionar headers de autenticação
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Adicionar imagens
      for (int i = 0; i < imageFiles.length; i++) {
        http.MultipartFile multipartFile;
        String fileName = kIsWeb ? imageFiles[i].name : imageFiles[i].path;
        String mime = '';
        if (fileName.toLowerCase().endsWith('.png')) {
          mime = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
          mime = 'image/jpeg';
        } else if (fileName.toLowerCase().endsWith('.webp')) {
          mime = 'image/webp';
        } else if (fileName.toLowerCase().endsWith('.gif')) {
          mime = 'image/gif';
        } else if (fileName.toLowerCase().endsWith('.bmp')) {
          mime = 'image/bmp';
        } else if (fileName.toLowerCase().endsWith('.tiff')) {
          mime = 'image/tiff';
        } else {
          mime = 'image/jpeg';
        }
        if (kIsWeb) {
          Uint8List bytes = await imageFiles[i].readAsBytes();
          multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: 'additional_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        } else {
          multipartFile = await http.MultipartFile.fromPath(
            'images',
            imageFiles[i].path,
            filename: 'additional_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        }
        request.files.add(multipartFile);
      }
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        
        return List<String>.from(jsonResponse['new_images']);
      } else {
        throw Exception('Erro no upload: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer upload: $e');
    }
  }
  
  /// Validar imagem antes do upload
  static Future<bool> validateImage(XFile imageFile) async {
    try {
      // Verificar tamanho do arquivo (máximo 5MB)
      int fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        return false;
      }
      
      // Verificar formato
      String fileName = imageFile.name.toLowerCase();
      List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp', '.tiff'];
      
      bool hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith(ext));
      return hasValidExtension;
    } catch (e) {
      return false;
    }
  }
}

// Extensão para o OwnerService
extension OwnerServiceImageUpload on OwnerService {
  
  /// Criar veículo com upload de imagens (versão simplificada)
  static Future<Map<String, dynamic>> createCarWithImages(
    Map<String, dynamic> vehicleData,
    List<XFile> imageFiles,
  ) async {
    try {
      // Validar todas as imagens primeiro
      List<XFile> validImages = [];
      for (XFile image in imageFiles) {
        if (await ImageUploadService.validateImage(image)) {
          validImages.add(image);
        }
      }
      
      // Criar veículo com imagens em uma única requisição
      var result = await ImageUploadService.createVehicleWithImages(
        vehicleData,
        validImages,
      );
      
      return result;
      
    } catch (e) {
      throw Exception('Erro ao criar veículo com imagens: $e');
    }
  }

  /// Atualizar veículo existente com PATCH e upload de imagens
  static Future<void> updateCarWithImages(
    String carId,
    Map<String, dynamic> vehicleData,
    List<XFile> imageFiles,
  ) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${baseUrl}/owner/car/$carId'),
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'multipart/form-data';
      vehicleData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      // Enviar existingImages como JSON string
      if (vehicleData['existingImages'] != null) {
        request.fields['existingImages'] = json.encode(vehicleData['existingImages']);
      }
      for (int i = 0; i < imageFiles.length; i++) {
        http.MultipartFile multipartFile;
        String fileName = kIsWeb ? imageFiles[i].name : imageFiles[i].path;
        String mime = '';
        if (fileName.toLowerCase().endsWith('.png')) {
          mime = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
          mime = 'image/jpeg';
        } else if (fileName.toLowerCase().endsWith('.webp')) {
          mime = 'image/webp';
        } else if (fileName.toLowerCase().endsWith('.gif')) {
          mime = 'image/gif';
        } else if (fileName.toLowerCase().endsWith('.bmp')) {
          mime = 'image/bmp';
        } else if (fileName.toLowerCase().endsWith('.tiff')) {
          mime = 'image/tiff';
        } else {
          mime = 'image/jpeg';
        }
        if (kIsWeb) {
          Uint8List bytes = await imageFiles[i].readAsBytes();
          multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: 'vehicle_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        } else {
          multipartFile = await http.MultipartFile.fromPath(
            'images',
            imageFiles[i].path,
            filename: 'vehicle_image_$i.jpg',
            contentType: MediaType.parse(mime),
          );
        }
        request.files.add(multipartFile);
      }
      var response = await request.send();
      if (response.statusCode != 200) {
        var errorData = await response.stream.bytesToString();
        throw Exception('Erro ao atualizar veículo: ${response.statusCode} $errorData');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar veículo: $e');
    }
  }
}