import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/models/register_data.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final RegisterData registerData =
        ModalRoute.of(context)!.settings.arguments as RegisterData;

    String? validateOtp(String? value) {
      if (value == null || value.isEmpty) {
        return l10n.codeRequired;
      }
      if (value.length != 6) {
        return l10n.codeInvalid;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.verifyEmail),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),

              Text(
                l10n.enterVerificationCode,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                l10n.codeSentTo(registerData.email),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 30),

              /// OTP FIELD
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                validator: validateOtp,
                decoration: InputDecoration(
                  hintText: '------',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// VERIFY BUTTON
              BlocConsumer<AuthCubit, Map<String, dynamic>>(
                listener: (context, state) {
                  if (state['state'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state['message'] ??
                              l10n.registrationSuccessful,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/profile-picture-setup',
                      (_) => false,
                    );
                  }
                  else {
                    print( state );
                    print( state['message'] );
                    print( state['state'] );
                  }

                },
                builder: (context, state) {
                  return ProgressButton(
                    label: l10n.verifyAndCreateAccount,
                    isLoading: state['state'] == 'loading',
                    isError: state['state'] == 'error',
                    errorMessage: state['message'],
                    backgroundColor: theme.colorScheme.primary,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().completeRegister(
                              data: registerData,
                              otp: _otpController.text,
                            );
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              /// RESEND CODE
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().sendRegisterOtp(
                        email: registerData.email,
                      );
                },
                child: Text(
                  l10n.resendCode,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
