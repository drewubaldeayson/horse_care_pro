import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: AppConstants.primaryColor,
        elevation: 0,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          // Replace headline6
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          // Replace bodyText2
          color: Colors.black54,
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppConstants.primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
