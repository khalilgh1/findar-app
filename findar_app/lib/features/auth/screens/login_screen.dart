import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import '../../../core/widgets/progress_button.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Validate email format
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                const Text(
                  'FinDAR',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                 Text(
                  'Welcome Back!',
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
                    'Email Address',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      )
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      )
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.blue,
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
                        const SnackBar(
                          content: Text('Login successful'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushNamed(context, '/home');
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state['state'] == 'loading';
                    final isError = state['state'] == 'error';
                    final errorMessage = isError ? (state['message'] as String?) : null;

                    return ProgressButton(
                      onPressed: () {
                        final emailError = _validateEmail(_emailController.text);
                        if (emailError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(emailError)),
                          );
                          return;
                        }

                        if (_passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password is required')),
                          );
                          return;
                        }

                        context.read<AuthCubit>().login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                      label: 'Login',
                      isLoading: isLoading,
                      isError: isError,
                      errorMessage: errorMessage,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color:theme.colorScheme.onSurface, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue,
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
    );
  }
}
