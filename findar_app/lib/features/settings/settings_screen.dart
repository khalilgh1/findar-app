import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Appearance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Appearance',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _buildDarkModeToggle(themeProvider, colorScheme, textTheme),

          const SizedBox(height: 24),

          // Language Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Language',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _buildLanguageOption('English', colorScheme, textTheme),
          _buildLanguageOption('Arabic', colorScheme, textTheme),

          const SizedBox(height: 24),

          // Contact Us Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Contact Us',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _buildContactOption(
            icon: Icons.phone,
            title: '+1 (234) 567-890',
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () {
              // Handle phone call
            },
          ),
          _buildContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Twitter',
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () {
              // Handle Twitter
            },
          ),
          _buildContactOption(
            icon: Icons.facebook,
            title: 'Facebook',
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () {
              // Handle Facebook
            },
          ),
          _buildContactOption(
            icon: Icons.camera_alt,
            title: 'Instagram',
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () {
              // Handle Instagram
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(ThemeProvider themeProvider, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
            color: colorScheme.onSurface,
            size: 30,
          ),
        ),
        title: Text(
          'Dark Mode',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = _selectedLanguage == language;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        title: Text(
          language,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 18,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check,
                color: colorScheme.primary,
                size: 28,
              )
            : null,
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
          // TODO: Implement language change logic
        },
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onSurface,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: colorScheme.onSurface.withOpacity(0.3),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}