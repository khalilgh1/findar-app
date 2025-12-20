import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/settings_cubit.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/language_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Settings are initialized in SettingsCubit constructor
  }

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
          AppLocalizations.of(context)!.settings,
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
              AppLocalizations.of(context)!.appearance,
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
              AppLocalizations.of(context)!.language,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _buildLanguageOption('English', colorScheme, textTheme),
          _buildLanguageOption('Arabic', colorScheme, textTheme),
          _buildLanguageOption('French', colorScheme, textTheme),

          const SizedBox(height: 24),

          // Contact Us Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              AppLocalizations.of(context)!.contactUs,
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
    return BlocBuilder<SettingsCubit, Map<String, dynamic>>(
      builder: (context, state) {
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
              AppLocalizations.of(context)!.darkMode,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            trailing: Switch(
              value: state['darkMode'] as bool? ?? false,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleDarkMode();
                themeProvider.toggleTheme(value);
              },
              activeColor: colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, ColorScheme colorScheme, TextTheme textTheme) {
    return BlocBuilder<LanguageCubit, String>(
      builder: (context, currentLanguage) {
        final languageMap = {'English': 'en', 'Arabic': 'ar', 'French': 'fr'};
        final isSelected = languageMap[language] == currentLanguage;

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
              context.read<LanguageCubit>().changeLanguage(languageMap[language]!);
            },
          ),
        );
      },
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