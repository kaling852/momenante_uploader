import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF00796B),
  hintColor: const Color(0xFFFF5722),
  scaffoldBackgroundColor: const Color(0xFF303030),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
    displayLarge: TextStyle(color: Color(0xFFFF5722)),
    titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
  ),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF00796B),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFFF5722),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00796B),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF00796B),
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Color(0xFF424242),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
    contentTextStyle: TextStyle(
      color: Color(0xFFE0E0E0),
    ),
  ),
);
