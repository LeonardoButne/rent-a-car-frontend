import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://api.bxc.co.mz:4002/api'; 