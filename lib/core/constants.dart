import 'package:flutter/material.dart';

class AppConstants {
  // App Configuration
  static const String appName = 'Horse Care Pro';

  // Colors
  static const Color primaryColor = Color(0xFF8B4513); // Brown
  static const Color accentColor = Color(0xFFD2691E);

  // Styles
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;

  // API and Firebase Constants
  static const String apiBaseUrl = 'https://your-api-endpoint.com';

  // Validation Regex
  static final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
}
