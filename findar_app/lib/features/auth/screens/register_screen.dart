import 'dart:convert';

import 'package:findar/models/register_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/l10n/app_localizations.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool unique_email = true;
  String? _selectedAccountType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  _emailChanged(String value) {
    setState(() {
      unique_email = true;
    });
  }

  _email_not_unique() {
    setState(() {
      unique_email = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var l10n = AppLocalizations.of(context)!;

    /// Validate name - defined here to access l10n
    String? validateName(String? name) {
      if (name == null || name.isEmpty) {
        return l10n.nameRequired;
      }
      if (name.length < 4) {
        return l10n.nameTooShort;
      }
      return null;
    }

    /// Validate password strength
    /// Requirements:
    /// - Minimum 8 characters
    /// - At least one uppercase letter
    /// - At least one lowercase letter
    /// - At least one number
    String? validatePassword(String? password) {
      if (password == null || password.isEmpty) {
        return l10n.passwordRequired;
      }
      if (password.length < 8) {
        return l10n.passwordTooShort;
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        return l10n.passwordMissingUppercase;
      }
      if (!password.contains(RegExp(r'[a-z]'))) {
        return l10n.passwordMissingLowercase;
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        return l10n.passwordMissingNumber;
      }
      return null;
    }

    /// Validate email format
    String? validateEmail(String? email) {
      if (email == null || email.isEmpty) {
        return l10n.emailRequired;
      }
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email)) {
        return l10n.invalidEmail;
      }
      if (!unique_email) {
        return l10n.uniqueEmailError;
      }
      return null;
    }

    /// Validate phone number (basic check)
    String? validatePhone(String? phone) {
      if (phone == null || phone.isEmpty) {
        return l10n.phoneRequired;
      }
      if (phone.length < 10) {
        return l10n.phoneTooShort;
      }
      return null;
    }

    String? validateAccountType(String? type) {
      if (type == null || type.isEmpty) {
        return l10n.accountTypeRequired;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'FinDAR',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.completeRegistration,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      hintText: l10n.selectAccountType,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    hint: Text(
                      l10n.selectAccountType,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'individual', // API value
                        child: Text(l10n.accountIndividual), // Display text
                      ),
                      DropdownMenuItem<String>(
                        value: 'agency', // API value
                        child: Text(l10n.accountAgency), // Display text
                      ),
                    ],
                    validator: validateAccountType,
                    onChanged: (String? newValue) {
                      setState(() => _selectedAccountType = newValue);
                    },
                    initialValue: _selectedAccountType,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.fullName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: validateName,
                    decoration: InputDecoration(
                      hintText: l10n.enterFullName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.emailAddress,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    onChanged: _emailChanged,
                    validator: validateEmail,
                    forceErrorText:
                        unique_email ? null : l10n.uniqueEmailError,
                    decoration: InputDecoration(
                      hintText: l10n.enterEmail,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.phoneNumber,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phonenumberController,
                    validator: validatePhone,
                    decoration: InputDecoration(
                      hintText: l10n.enterPhone,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.password,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: validatePassword,
                    decoration: InputDecoration(
                      hintText: l10n.enterPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                  BlocConsumer<AuthCubit, Map<String, dynamic>>(
                    listener: (context, state) {
                      if (state['state'] == 'done') {
                        Navigator.pushNamed(
                        context,
                        '/verify-email',
                        arguments: RegisterData(
                          name: _nameController.text,
                          email: _emailController.text,
                          phone: _phonenumberController.text,
                          password: _passwordController.text,
                          accountType: _selectedAccountType!,
                        ),
                      );
                      }
                      if (state['state'] == 'error') {
                        final errorMessage =
                          (state['message'] as String?);
                      if (errorMessage != null) {
                        if (errorMessage.contains("email")){
                          _email_not_unique();
                        } 
                      }
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state['state'] == 'loading';
                      final isError = state['state'] == 'error';
                      final errorMessage =
                          isError ? (state['message'] as String?) : null;

                      return ProgressButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().sendRegisterOtp(
                                  email: _emailController.text,
                                );
                          }
                        },
                        label: l10n.registerNow,
                        isLoading: isLoading,
                        isError: isError,
                        errorMessage: errorMessage,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          l10n.login,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
