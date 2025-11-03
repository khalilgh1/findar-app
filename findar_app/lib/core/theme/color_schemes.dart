import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  
  // Primary colors - Brand blue with better shades
  primary: Color(0xFF0066CC),        // More vibrant blue
  onPrimary: Color(0xFFFFFFFF),      // White text on primary
  primaryContainer: Color(0xFFE0EDFF), // Light blue container
  onPrimaryContainer: Color(0xFF003366), // Dark blue text on primary container
  
  // Secondary colors - Complementary colors
  secondary: Color.fromARGB(255, 232, 235, 240),       // Muted slate gray
  onSecondary: Color(0xFFFFFFFF),     // White text on secondary
  secondaryContainer: Color.fromARGB(255, 237, 243, 248), // Very light blue-gray
  onSecondaryContainer: Color(0xFF374151), // Dark gray text
  
  // Surface colors - Background hierarchy
  surface: Color(0xFFFFFFFF),         // Pure white background
  onSurface: Color(0xFF1F2937),       // Dark gray text
  surfaceVariant: Color(0xFFF8FAFC),  // Slightly off-white for elevation
  onSurfaceVariant: Color(0xFF64748B), // Medium gray for less important text
  
  // Background colors
  background: Color(0xFFF9FAFB),      // Light gray background
  onBackground: Color(0xFF1F2937),    // Dark gray text
  
  // Error colors
  error: Color(0xFFDC2626),           // More vibrant red
  onError: Color(0xFFFFFFFF),         // White text on error
  errorContainer: Color(0xFFFEE2E2),  // Light red background
  onErrorContainer: Color(0xFF7F1D1D), // Dark red text
  
  // Success colors (using tertiary for success)
  tertiary: Color(0xFF059669),        // Success green
  onTertiary: Color(0xFFFFFFFF),      // White text on success
  tertiaryContainer: Color(0xFFD1FAE5), // Light green background
  onTertiaryContainer: Color(0xFF065F46), // Dark green text
  
  // Outline and shadow
  outline: Color(0xFFE5E7EB),         // Border color
  outlineVariant: Color(0xFFD1D5DB),  // Secondary border
  shadow: Color(0x1A000000),          // Subtle shadow
  scrim: Color(0x33000000),           // Overlay scrim
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  
  // Primary colors - Softer blues for dark mode
  primary: Color(0xFF3B82F6),         // Bright but not harsh blue
  onPrimary: Color(0xFF0F172A),       // Very dark blue text
  primaryContainer: Color(0xFF1E3A8A), // Dark blue container
  onPrimaryContainer: Color(0xFFDBEAFE), // Light blue text
  
  // Secondary colors - Warmer grays
  secondary: Color(0xFF94A3B8),       // Medium blue-gray
  onSecondary: Color(0xFF0F172A),     // Dark blue text
  secondaryContainer: Color(0xFF334155), // Dark gray-blue
  onSecondaryContainer: Color(0xFFCBD5E1), // Light gray text
  
  // Surface colors - Dark background hierarchy
  surface: Color(0xFF0F172A),         // Very dark blue background
  onSurface: Color(0xFFF1F5F9),       // Light gray text
  surfaceVariant: Color(0xFF1E293B),  // Slightly lighter dark blue
  onSurfaceVariant: Color(0xFF94A3B8), // Medium gray for less important text
  
  // Background colors
  background: Color(0xFF0A0F1C),      // Darker blue background
  onBackground: Color(0xFFE2E8F0),    // Light gray text
  
  // Error colors
  error: Color(0xFFEF4444),           // Bright red
  onError: Color(0xFF450A0A),         // Dark red text
  errorContainer: Color(0xFF7F1D1D),  // Dark red background
  onErrorContainer: Color(0xFFFECACA), // Light red text
  
  // Success colors (using tertiary for success)
  tertiary: Color(0xFF10B981),        // Bright success green
  onTertiary: Color(0xFF047857),      // Dark green text
  tertiaryContainer: Color(0xFF065F46), // Dark green background
  onTertiaryContainer: Color(0xFFA7F3D0), // Light green text
  
  // Outline and shadow
  outline: Color(0xFF334155),         // Border color
  outlineVariant: Color(0xFF475569),  // Secondary border
  shadow: Color(0x33000000),          // Dark shadow
  scrim: Color(0x66000000),           // Darker overlay scrim
);