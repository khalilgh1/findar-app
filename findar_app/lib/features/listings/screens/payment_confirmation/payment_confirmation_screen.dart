import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/sponsorship_plan.dart';
import '../../../../core/models/property_listing_model.dart';
import '../../../../logic/cubits/boost_cubit.dart';
// import '../../../../logic/cubits/listing_cubit.dart'; // Disabled - has incompatible methods
import '../../../../core/widgets/progress_button.dart';
import 'widgets/order_summary.dart';
import 'widgets/payment_form.dart';
import 'package:findar/l10n/app_localizations.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final PropertyListing listing;
  final SponsorshipPlan plan;

  const PaymentConfirmationScreen({
    super.key,
    required this.listing,
    required this.plan,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _handleBoostSuccess(Map<String, dynamic> boostedData) {
    try {
      // TODO: Update boost status when ListingCubit is re-enabled
      // context.read<ListingCubit>().updateBoostStatus(
      //   listingId: boostedData['listingId'],
      //   sponsorshipPlanId: boostedData['sponsorshipPlanId'],
      //   boostExpiryDate: DateTime.parse(boostedData['boostExpiryDate']),
      // );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.propertyBoostedSuccessfully);
            },
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      _showError('Error updating listing: ${e.toString()}');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  void _handlePayment() {
    if (_formKey.currentState!.validate()) {
      context.read<BoostCubit>().boostListing(
        listingId: widget.listing.id,
        planId: widget.plan.id,
        durationMonths: widget.plan.durationMonths,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: false,
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.paymentConfirmation,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
      body: BlocConsumer<BoostCubit, Map<String, dynamic>>(
        listener: (context, state) {
          if (state['state'] == 'done') {
            _handleBoostSuccess(state['data']);
          } else if (state['state'] == 'error') {
            _showError(state['message'] ?? 'Payment failed');
          }
        },
        builder: (context, state) {
          final isLoading = state['state'] == 'loading';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderSummary(
                  listing: widget.listing,
                  plan: widget.plan,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PaymentForm(
                        formKey: _formKey,
                        cardNumberController: _cardNumberController,
                        cardholderNameController: _cardholderNameController,
                        expiryDateController: _expiryDateController,
                        cvvController: _cvvController,
                      ),
                      const SizedBox(height: 32),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return ProgressButton(
                            label: l10n.payNow,
                            isLoading: isLoading,
                            backgroundColor: theme.colorScheme.primary,
                            textColor: Colors.white,
                            onPressed: _handlePayment,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
