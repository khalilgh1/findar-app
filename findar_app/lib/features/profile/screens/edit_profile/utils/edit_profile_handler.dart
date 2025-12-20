import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';

/// Handles the logic for saving profile changes
class EditProfileHandler {
  /// Handle save changes
  static Future<void> saveChanges({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);

    try {
      await context.read<ProfileCubit>().updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (!context.mounted) return;

      final state = context.read<ProfileCubit>().state;
      
      if (state['state'] == 'done') {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state['message'] ?? 'Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to profile screen
        Navigator.pop(context);
      } else if (state['state'] == 'error') {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state['message'] ?? 'Failed to update profile'),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }
}
