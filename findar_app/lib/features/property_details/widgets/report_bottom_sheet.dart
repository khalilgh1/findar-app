import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportSuggestion {
  final String Function(AppLocalizations) titleBuilder;
  final IconData icon;

  const ReportSuggestion({
    required this.titleBuilder,
    required this.icon,
  });

  static List<ReportSuggestion> get suggestions => [
    ReportSuggestion(
      titleBuilder: (l10n) => l10n.inaccurateInformation,
      icon: Icons.info_outline,
    ),
    ReportSuggestion(
      titleBuilder: (l10n) => l10n.fraudulentListing,
      icon: Icons.warning_amber_outlined,
    ),
    ReportSuggestion(
      titleBuilder: (l10n) => l10n.inappropriateContent,
      icon: Icons.block_outlined,
    ),
    ReportSuggestion(
      titleBuilder: (l10n) => l10n.propertyNotAvailable,
      icon: Icons.home_outlined,
    ),
  ];
}

class ReportBottomSheet extends StatefulWidget {
  final Function(String) onReasonSelected;
  final String? propertyId;

  const ReportBottomSheet({
    super.key,
    required this.onReasonSelected,
    this.propertyId,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isValidEmail = true;
  String? _selectedSuggestion;

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submitReport() async {
    final reportText = _controller.text.trim();
    final userEmail = _emailController.text.trim();
    
    setState(() {
      _isValidEmail = userEmail.isEmpty || _isEmailValid(userEmail);
    });
    
    if (reportText.isNotEmpty && userEmail.isNotEmpty && _isValidEmail) {
      final subject = 'Property Report - ${widget.propertyId ?? "Unknown"}';
      final body = '''
Property Report

Issue Description:
$reportText

Reporter Email: $userEmail
Property ID: ${widget.propertyId ?? "Unknown"}

This report was submitted through the Findar mobile app.
      ''';
      
      final emailUri = Uri(
        scheme: 'mailto',
        path: 'support@findar.com', // Replace with your support email
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );
      
      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          
          widget.onReasonSelected(reportText);
          Navigator.pop(context);
        }
      } catch (e) {
        print('Email launch error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: screenWidth * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: Colors.red[600],
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  l10n.reportProperty,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Help us maintain quality listings by reporting issues.',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            
            // Quick suggestions
            Text(
              'Quick suggestions:',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: ReportSuggestion.suggestions.map((suggestion) {
                final title = suggestion.titleBuilder(l10n);
                final isSelected = _selectedSuggestion == title;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSuggestion = null;
                        _controller.clear();
                      } else {
                        _selectedSuggestion = title;
                        _controller.text = title;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          suggestion.icon,
                          size: screenWidth * 0.04,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            SizedBox(height: screenHeight * 0.025),
            
            // Description field
            Text(
              'Describe the issue:',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Please provide details about the issue...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: screenWidth * 0.035,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.all(screenWidth * 0.04),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Email field
            Text(
              'Your email (optional):',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'your.email@example.com',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: screenWidth * 0.035,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(
                    color: _isValidEmail ? Colors.grey[300]! : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: BorderSide(
                    color: _isValidEmail 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.red,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: EdgeInsets.all(screenWidth * 0.04),
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                suffixIcon: Icon(
                  Icons.email_outlined,
                  color: Colors.grey[400],
                  size: screenWidth * 0.05,
                ),
              ),
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (!_isValidEmail)
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.005,
                  left: screenWidth * 0.04,
                ),
                child: Text(
                  'Please enter a valid email address',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  'Send Report',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
