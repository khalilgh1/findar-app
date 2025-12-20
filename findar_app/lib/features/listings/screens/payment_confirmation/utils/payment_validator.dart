class PaymentValidator {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    if (value.length < 13) {
      return 'Card number must be at least 13 digits';
    }
    return null;
  }

  static String? validateCardholderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cardholder name is required';
    }
    if (value.length < 3) {
      return 'Cardholder name must be at least 3 characters';
    }
    // Check if contains any digits
    if (value.contains(RegExp(r'\d'))) {
      return 'Cardholder name cannot contain numbers';
    }
    // Check if contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Cardholder name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    // Remove slash for validation
    final digitsOnly = value.replaceAll('/', '');
    if (digitsOnly.length != 4) {
      return 'Expiry date must be in MM/YY format';
    }
    
    // Validate month (first 2 digits)
    final month = int.tryParse(digitsOnly.substring(0, 2));
    if (month == null || month < 1 || month > 12) {
      return 'Enter valid month between 01 and 12';
    }
    
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3) {
      return 'CVV must be at least 3 digits';
    }
    return null;
  }

  static bool validateAllFields({
    required String cardNumber,
    required String cardholderName,
    required String expiryDate,
    required String cvv,
    required Function(String) showError,
  }) {
    String? error;

    error = validateCardNumber(cardNumber);
    if (error != null) {
      showError(error);
      return false;
    }

    error = validateCardholderName(cardholderName);
    if (error != null) {
      showError(error);
      return false;
    }

    error = validateExpiryDate(expiryDate);
    if (error != null) {
      showError(error);
      return false;
    }

    error = validateCVV(cvv);
    if (error != null) {
      showError(error);
      return false;
    }

    return true;
  }
}
