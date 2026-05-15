import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = "http://192.168.31.246:9000";

  static const Color primaryBlue = Color(0xFF1A365D);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color inactiveRed = Color(0xFFF44336);
  static const Color textDark = Color(0xFF333333);
  static const Color cardShadow = Color(0x1A000000);

  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
}
