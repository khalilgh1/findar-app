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
  String? _selectedSuggestion;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final reportText = _controller.text.trim();
    
    if (reportText.isEmpty) {
      _showErrorDialog('Please select or describe the issue before submitting.');
      return;
    }
    
    final subject = 'Property Report - ${widget.propertyId ?? "Unknown"}';
    final body = '''Property Report

Issue Description:
$reportText

Property ID: ${widget.propertyId ?? "Unknown"}

This report was submitted through the Findar mobile app.''';
    
    // Try different approaches to launch email
    await _tryLaunchEmail(subject, body);
  }

  Future<void> _tryLaunchEmail(String subject, String body) async {
    // Method 1: Try standard mailto with proper encoding
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'dibishak.23@gmail.com',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    try {
      // First try: Standard mailto
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        widget.onReasonSelected(_controller.text.trim());
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      print('Standard mailto failed: $e');
    }
    
    try {
      // Second try: Gmail specific intent
      final gmailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&to=dibishak.23@gmail.com&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      );
      
      final launched = await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        widget.onReasonSelected(_controller.text.trim());
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      print('Gmail web intent failed: $e');
    }
    
    try {
      // Third try: Any available email app
      final genericEmailUri = Uri.parse('mailto:dibishak.23@gmail.com');
      
      final launched = await launchUrl(
        genericEmailUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        // Show a dialog with the report details for manual entry
        _showManualReportDialog(subject, body);
        return;
      }
    } catch (e) {
      print('Generic mailto failed: $e');
    }
    
    // All methods failed - show instructions
    _showEmailInstructionsDialog(subject, body);
  }

  void _showManualReportDialog(String subject, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email App Opened'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('An email app should have opened. If the details aren\'t filled automatically, please copy this information:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To: dibishak.23@gmail.com', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Message:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(body, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onReasonSelected(_controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmailInstructionsDialog(String subject, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Send Report Manually'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please send this report manually using your preferred email app:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCopyableField('To:', 'dibishak.23@gmail.com'),
                    const Divider(height: 16),
                    _buildCopyableField('Subject:', subject),
                    const Divider(height: 16),
                    _buildCopyableField('Message:', body),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps:\n1. Open Gmail or your email app\n2. Compose new email\n3. Copy the details above\n4. Send the email',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onReasonSelected(_controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
