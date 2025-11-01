import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFF007BFF), // blue brand color
  onPrimary: Color(0xFFFFFFFF), // text color on buttons ..etc

  secondary: Color.fromARGB(
    255,
    172,
    174,
    176,
  ), // light color for text ( description ..ect )
  onSecondary: Color.fromARGB(
    255,
    143,
    154,
    163,
  ), // grey color for (labels, icons)

  error: Color(0xFFF7CBCB), // Error background
  onError: Color(0xFFED1515), // Error text

  secondaryContainer: Color(0xFFFFFFFF), // background for cards, sheets
  onSecondaryContainer: Color(0xFF1E1E1E), // text headings inside cards

  surface: Color.fromARGB(247, 246, 247, 241), //  App background for scaffolds
  onSurface: Color(0xFF000000), // Text on the background

  shadow: Color.fromARGB(255, 107, 104, 104), // containers shadow
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF007BFF), // blue brand color
  secondary: Color(0xFF3A4756), // dark secondary color
  onPrimary: Color(0xFFFFFFFF), // text color on buttons ..etc
  onSecondary: Color(0xFFCFE3F6), // Text on secondary (labels, icons)
  error: Color(0xFFED1515), // Error background
  onError: Color(0xFFF7CBCB), // Error text
  surface: Color(0xFF1E1E1E), // background for cards, sheets
  onSurface: Color(0xFFFFFFFF), // App background for scaffolds
);
