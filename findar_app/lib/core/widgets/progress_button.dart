import 'package:flutter/material.dart';

/// Reusable Progress Button widget for form submissions
/// Shows loading spinner while submit is in progress
/// Displays error message if submission fails
/// Includes built-in cooldown to prevent button spam
/// 
/// Usage:
/// ```dart
/// ProgressButton(
///   onPressed: () {
///     context.read<AuthCubit>().register(
///       email: emailController.text,
///       password: passwordController.text,
///     );
///   },
///   isLoading: state['state'] == 'loading',
///   isError: state['state'] == 'error',
///   errorMessage: state['message'],
///   label: 'Register',
/// )
/// ```
class ProgressButton extends StatefulWidget {
  /// Callback when button is pressed
  /// Will not be called if button is loading or disabled
  final VoidCallback? onPressed;

  /// Whether the button should show loading spinner
  final bool isLoading;

  /// Whether the button should show error state
  final bool isError;

  /// Error message to display in error state
  final String? errorMessage;

  /// Button label text
  final String label;

  /// Optional: Whether to disable the button
  /// Useful for form validation
  final bool isEnabled;

  /// Optional: Background color of the button
  final Color? backgroundColor;

  /// Optional: Text color of the button
  final Color? textColor;

  /// Optional: Icon to show on the button
  final IconData? icon;

  /// Optional: Button width (if not provided, uses full width)
  final double? width;

  /// Optional: Button height (default: 50)
  final double height;

  /// Optional: Border radius (default: 12)
  final double borderRadius;

  /// Cooldown duration in milliseconds (default: 500ms)
  /// Prevents button spam during this time
  final int cooldownMs;

  const ProgressButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.cooldownMs = 1500,
  }) : super(key: key);

  @override
  State<ProgressButton> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> {
  bool _isInCooldown = false;

  void _handleButtonPress() {
    if (_isInCooldown) return;
    
    if (widget.onPressed != null) {
      widget.onPressed!();
      
      // Start cooldown
      setState(() {
        _isInCooldown = true;
      });
      
      Future.delayed(Duration(milliseconds: widget.cooldownMs), () {
        if (mounted) {
          setState(() {
            _isInCooldown = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if button should be clickable
    final canPress = !widget.isLoading && widget.isEnabled && !widget.isError && !_isInCooldown;

    // Determine button color
    final bgColor = widget.isError
        ? Colors.red.shade100
        : (widget.isLoading || _isInCooldown ? Colors.grey.shade400 : (widget.backgroundColor ?? Theme.of(context).primaryColor));

    final textCol = widget.isError ? Colors.red : (widget.textColor ?? Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main button
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: ElevatedButton(
            onPressed: canPress ? _handleButtonPress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              disabledBackgroundColor: bgColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              elevation: widget.isError ? 0 : 2,
            ),
            child: widget.isLoading
                ? _buildLoadingContent(textCol)
                : _buildNormalContent(textCol),
          ),
        ),
        // Error message display
        if (widget.isError && widget.errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build button content when loading
  Widget _buildLoadingContent(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Please wait...',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Build button content when not loading
  Widget _buildNormalContent(Color textColor) {
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}
