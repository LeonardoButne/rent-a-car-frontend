import 'package:flutter/foundation.dart' show kIsWeb;

/// Retorna a BASE_URL correta conforme a plataforma (web ou mobile)
String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:4002/api';
  } else {
    // Para Android Studio emulador
    return 'http://10.0.2.2:4002/api';
  }
} 