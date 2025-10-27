import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF007BFF), // blue brand color
  secondary: Color(0xFFCFE3F6), // light secondary color
  onPrimary: Color(0xFFFFFFFF), // text color on buttons ..etc
  onSecondary: Color(0xFF5C6575), // Text on secondary (labels, icons)
  error: Color(0xFFF7CBCB), // Error background
  onError: Color(0xFFED1515), // Error text
  surface: Color(0xFFFFFFFF), // background for cards, sheets
  onSurface: Color(0xFF111111), // App background for scaffolds
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF007BFF), // blue brand color
  secondary: Color(0xFF3A4756), // dark secondary color
  onPrimary: Color(0xFF000000), // text color on buttons ..etc
  onSecondary: Color(0xFFCFE3F6), // Text on secondary (labels, icons)
  error: Color(0xFFED1515), // Error background
  onError: Color(0xFFF7CBCB), // Error text
  surface: Color(0xFF1E1E1E), // background for cards, sheets
  onSurface: Color(0xFFFFFFFF), // App background for scaffolds
);
