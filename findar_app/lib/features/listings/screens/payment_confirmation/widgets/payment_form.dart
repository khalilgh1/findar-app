import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/expiry_date_formatter.dart';
import '../utils/payment_validator.dart';

class PaymentForm extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController cardholderNameController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;
  final GlobalKey<FormState> formKey;

  const PaymentForm({
    super.key,
    required this.cardNumberController,
    required this.cardholderNameController,
    required this.expiryDateController,
    required this.cvvController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
            Image.asset(
              'assets/edahabia_logo.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.credit_card,
                  color: theme.colorScheme.primary,
                  size: 30,
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Pay with your EDAHABIA Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Card Number
        _buildLabel('Card Number', theme),
        const SizedBox(height: 6),
        _buildTextField(
          controller: cardNumberController,
          hintText: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: PaymentValidator.validateCardNumber,
        ),
        const SizedBox(height: 20),

        // Cardholder Name
        _buildLabel('Cardholder Name', theme),
        const SizedBox(height: 6),
        _buildTextField(
          controller: cardholderNameController,
          hintText: 'John Doe',
          keyboardType: TextInputType.name,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          validator: PaymentValidator.validateCardholderName,
        ),
        const SizedBox(height: 20),

        // Expiry Date and CVV
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Expiry Date', theme),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: expiryDateController,
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      ExpiryDateFormatter(),
                    ],
                    validator: PaymentValidator.validateExpiryDate,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CVV', theme),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: cvvController,
                    hintText: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: PaymentValidator.validateCVV,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
