import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:findar/core/services/firebase_oauth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  var l10n = AppLocalizations.of(context)!;
  
  /// Validate email format - defined here to access l10n
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return l10n.emailRequired;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return l10n.passwordRequired;
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
                const SizedBox(height: 120),
                Text(
                  'FinDAR',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                 Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    color: Theme.of( context).colorScheme.onSurface,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
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
                  validator: validateEmail,
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
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BlocConsumer<AuthCubit, Map<String, dynamic>>(
                  listener: (context, state) {
                    if (state['state'] == 'done') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.success),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    }
                    if (state['state'] == 'error' && state['message'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state['message'] as String),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      // Clear error state after showing message
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          context.read<AuthCubit>().clearError();
                        }
                      });
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state['state'] == 'loading';

                    return ProgressButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().login(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        }
                      },
                      label: l10n.login,
                      isLoading: isLoading,
                      backgroundColor: theme.colorScheme.primary,
                      textColor: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await FirebaseOAuthService().signInWithGoogle();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.success),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushNamed(context, '/home');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Google sign-in failed: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BlocConsumer<AuthCubit, Map<String, dynamic>>(
                  listener: (context, state) {
                    if (state['state'] == 'done' && state['data'] != null) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    }
                    if (state['state'] == 'error' && state['message'] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state['message'] as String)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state['state'] == 'loading';
                    return ProgressButton(
                      onPressed: isLoading
                          ? null
                          : () {
                // Seed a debug cached user into SharedPreferences, then load it
                final cubit = context.read<AuthCubit>();
                LocalUserStore()
                  .seedDebugUser()
                  .then((_) => cubit.loadCachedUser());
                            },
                      label: 'Access cached user',
                      isLoading: isLoading,
                      backgroundColor: theme.colorScheme.secondary,
                      textColor: theme.colorScheme.onSecondary,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: TextStyle(color:theme.colorScheme.onSurface, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        l10n.register,
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
