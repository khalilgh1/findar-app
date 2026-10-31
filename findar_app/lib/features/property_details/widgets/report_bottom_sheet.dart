import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/models/return_result.dart';

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
  /// Sends the report; the sheet closes itself when this succeeds.
  final Future<ReturnResult> Function(String reason) onSubmit;

  const ReportBottomSheet({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedSuggestion;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context)!;
    final reportText = _controller.text.trim();

    if (reportText.isEmpty) {
      _showErrorDialog(l10n.pleaseSelectOrDescribe);
      return;
    }

    setState(() => _isSending = true);
    final result = await widget.onSubmit(reportText);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (result.state) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.propertyReportedThankYou)),
      );
    } else {
      _showErrorDialog(result.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reportProperty),
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
              l10n.helpMaintainQuality,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            
            // Quick suggestions
            Text(
              l10n.quickSuggestions,
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
              l10n.describeIssue,
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
                hintText: l10n.provideDetails,
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
                onPressed: _isSending ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.sendReport,
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
