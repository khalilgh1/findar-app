import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/sponsorship_plan.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/listings/screens/payment_confirmation/boost_confirmed_screen.dart';
import 'package:findar/features/listings/screens/payment_confirmation/utils/expiry_date_formatter.dart';
import 'package:findar/features/listings/screens/payment_confirmation/utils/payment_validator.dart';
import 'package:findar/features/listings/screens/sponsorship_plans/sponsorship_plans_screen.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/boost_cubit.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';

/// Checkout. The design targets Chargily (Edahabia / CIB on Chargily's
/// hosted page); until the backend checkout + webhook exist, this keeps the
/// existing card form in the new look (see docs/roadmap.md, "Payments").
class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen(
      {super.key, required this.listing, required this.plan});
  final PropertyListing listing;
  final SponsorshipPlan plan;

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  int _shake = 0;

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _pay() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    context.read<BoostCubit>().boostListing(
          listingId: widget.listing.id,
          planId: widget.plan.id,
          durationMonths: widget.plan.durationMonths,
          cardNumber: _number.text,
          cardHolder: _holder.text,
          expiryDate: _expiry.text,
          cvv: _cvv.text,
        );
  }

  void _onSuccess() {
    HapticFeedback.mediumImpact();
    context.read<MyListingsCubit>().fetchMyListings(forceRefresh: true);
    context.read<SponsoredCubit>().getSponsoredListings(forceRefresh: true);
    context.read<PropertyDetailsCubit>().invalidateCache(widget.listing.id);
    context.read<BoostCubit>().reset();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) => BoostConfirmedScreen(listing: widget.listing)),
      (r) =>
          r.settings.name != '/payment-confirmation' &&
          r.settings.name != '/sponsorship-plans',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final plan = widget.plan;
    final total = formatPrice(context, plan.priceDZD);

    Widget row(String a, String b, {bool bold = false}) => Row(children: [
          Expanded(
            child: Text(a,
                style: bold
                    ? context.tt.titleSmall
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w800)
                    : context.tt.bodyMedium?.copyWith(
                        color: c.muted, fontWeight: FontWeight.w600)),
          ),
          Text(b,
              style: bold
                  ? context.tt.titleSmall
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.w800)
                  : context.tt.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
        ]);

    return BlocConsumer<BoostCubit, Map<String, dynamic>>(
      listener: (context, state) {
        if (state['state'] == 'done') _onSuccess();
        if (state['state'] == 'error') {
          setState(() => _shake++);
          showAppSnack(context, '${state['message'] ?? l10n.errorOccurred}');
        }
      },
      builder: (context, state) {
        final loading = state['state'] == 'loading';
        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            bottom: false,
            child: Column(children: [
              FTopBar(title: l10n.checkout),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: [
                      Text(l10n.orderSummary,
                          style: context.tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      FCard(
                        child: Column(children: [
                          Row(children: [
                            ListingPhoto(
                                url: widget.listing.image,
                                width: 56,
                                height: 56,
                                radius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.listing.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800)),
                                  Text(widget.listing.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.tt.bodySmall),
                                ],
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          const FDivider(),
                          const SizedBox(height: 12),
                          row(l10n.planLabel, plan.label(l10n)),
                          const SizedBox(height: 12),
                          row(l10n.durationLabel, l10n.daysCount(plan.days)),
                          const SizedBox(height: 12),
                          const FDivider(),
                          const SizedBox(height: 12),
                          row(l10n.totalLabel, total, bold: true),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.payWith,
                          style: context.tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      AppField(
                        label: l10n.cardNumber,
                        controller: _number,
                        hint: l10n.cardNumberHint,
                        icon: FIcons.card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        validator: PaymentValidator.validateCardNumber,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        label: l10n.cardholderName,
                        controller: _holder,
                        hint: l10n.cardholderNameHint,
                        icon: FIcons.user,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]')),
                        ],
                        validator: PaymentValidator.validateCardholderName,
                      ),
                      const SizedBox(height: 16),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppField(
                                label: l10n.expiryDate,
                                controller: _expiry,
                                hint: l10n.expiryDateHint,
                                keyboardType: TextInputType.number,
                                inputFormatters: [ExpiryDateFormatter()],
                                validator: PaymentValidator.validateExpiryDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppField(
                                label: l10n.cvv,
                                controller: _cvv,
                                hint: l10n.cvvHint,
                                obscure: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: PaymentValidator.validateCVV,
                              ),
                            ),
                          ]),
                      const SizedBox(height: 18),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FIcon(FIcons.shield, size: 18, color: c.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(l10n.securePaymentNote,
                                  style: context.tt.bodySmall
                                      ?.copyWith(height: 1.5)),
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
              StickyBar(
                child: ShakeOnChange(
                  trigger: _shake == 0 ? null : _shake,
                  child: FButton(
                    label: l10n.payAmount(total),
                    icon: FIcons.lock,
                    loading: loading,
                    onPressed: loading ? null : _pay,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
