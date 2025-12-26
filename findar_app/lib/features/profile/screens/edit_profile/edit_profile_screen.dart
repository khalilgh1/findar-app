import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/features/profile/screens/edit_profile/widgets/profile_text_field.dart';
import 'package:findar/features/profile/screens/edit_profile/utils/validators.dart';
import 'package:findar/features/profile/screens/edit_profile/utils/edit_profile_handler.dart';
import 'package:findar/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load current user data into form fields
  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = context.read<ProfileCubit>().state;
      final userData = profileState['data'] as Map<String, dynamic>?;
      
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.editProfile,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileCubit, Map<String, dynamic>>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                
                // Full Name Field
                ProfileTextField(
                  label: l10n.fullName,
                  controller: _nameController,
                  validator: ProfileValidators.validateName,
                  hintText: l10n.enterFullName,
                ),
                
                const SizedBox(height: 24),
                
                // Email Field
                ProfileTextField(
                  label: l10n.emailAddress,
                  controller: _emailController,
                  validator: ProfileValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  hintText: l10n.enterEmail,
                ),
                
                const SizedBox(height: 24),
                
                // Phone Number Field
                ProfileTextField(
                  label: l10n.phoneNumber,
                  controller: _phoneController,
                  validator: ProfileValidators.validatePhone,
                  keyboardType: TextInputType.phone,
                  hintText: l10n.enterPhone,
                ),
                
                const SizedBox(height: 40),
                
                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: ProgressButton(
                    label: l10n.saveChanges,
                    backgroundColor: theme.colorScheme.primary,
                    textColor: Colors.white,
                    isLoading: _isLoading,
                    onPressed: _isLoading
                        ? null
                        : () => EditProfileHandler.saveChanges(
                              context: context,
                              formKey: _formKey,
                              nameController: _nameController,
                              emailController: _emailController,
                              phoneController: _phoneController,
                              setLoading: _setLoading,
                            ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
