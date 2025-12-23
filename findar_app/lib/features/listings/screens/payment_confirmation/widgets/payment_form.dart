import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:findar/features/listings/screens/payment_confirmation/utils/expiry_date_formatter.dart';
import 'package:findar/features/listings/screens/payment_confirmation/utils/payment_validator.dart';
import 'package:findar/l10n/app_localizations.dart';

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

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        
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
            _buildLabel(l10n.cardNumber, theme),
            const SizedBox(height: 6),
            _buildTextField(
              controller: cardNumberController,
              hintText: l10n.cardNumberHint,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: PaymentValidator.validateCardNumber,
            ),
            const SizedBox(height: 20),

            // Cardholder Name
            _buildLabel(l10n.cardholderName, theme),
            const SizedBox(height: 6),
            _buildTextField(
              controller: cardholderNameController,
              hintText: l10n.cardholderNameHint,
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
                      _buildLabel(l10n.expiryDate, theme),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: expiryDateController,
                        hintText: l10n.expiryDateHint,
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
                  _buildLabel(l10n.cvv, theme),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: cvvController,
                    hintText: l10n.cvvHint,
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
      },
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
