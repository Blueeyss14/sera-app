import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseConfigs {
  BaseConfigs._();

  static final String baseUrl = dotenv.env['BASE_URL']!;
}
