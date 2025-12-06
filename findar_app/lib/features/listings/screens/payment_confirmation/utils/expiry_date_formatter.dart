import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 4 digits (MMYY)
    final limitedDigits = digitsOnly.substring(0, digitsOnly.length > 4 ? 4 : digitsOnly.length);
    
    String formatted = '';
    
    if (limitedDigits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Add first two digits (MM)
    formatted = limitedDigits.substring(0, limitedDigits.length >= 2 ? 2 : limitedDigits.length);
    
    // Add slash after MM if there are more digits
    if (limitedDigits.length >= 3) {
      formatted += '/' + limitedDigits.substring(2);
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
