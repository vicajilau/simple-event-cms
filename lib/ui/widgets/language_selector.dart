import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Widget for language selection with dropdown menu
/// Displays available languages with their native names and flags
class LanguageSelector extends StatelessWidget {
  /// Currently selected locale
  final Locale currentLocale;

  /// Callback when language is changed
  final ValueChanged<Locale> onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  /// List of supported languages with their display names and flag emojis
  static const List<Map<String, dynamic>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'gl', 'name': 'Galician', 'nativeName': 'Galego'},
    {'code': 'ca', 'name': 'Catalan', 'nativeName': 'Català'},
    {'code': 'eu', 'name': 'Basque', 'nativeName': 'Euskera'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
  ];

  /// Gets the display information for the current locale
  Map<String, dynamic>? get _currentLanguage {
    return _languages.firstWhere(
      (lang) => lang['code'] == currentLocale.languageCode,
      orElse: () => _languages[0], // Default to English
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = _currentLanguage;

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentLang?['nativeName'] ?? 'Language',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      tooltip:
          AppLocalizations.of(context)?.changeLanguage ?? 'Change Language',
      onSelected: onLanguageChanged,
      itemBuilder: (context) => _languages.map((language) {
        final locale = Locale(language['code']);
        final isSelected = locale.languageCode == currentLocale.languageCode;

        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language['nativeName'],
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    Text(
                      language['name'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Compact language selector for toolbar usage
/// Muestra solo el código del idioma
class CompactLanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageChanged;

  const CompactLanguageSelector({
    super.key,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentLang = LanguageSelector._languages.firstWhere(
      (lang) => lang['code'] == currentLocale.languageCode,
      orElse: () => LanguageSelector._languages[0],
    );

    return PopupMenuButton<Locale>(
      icon: Text(
        currentLang['code'].toString().toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      tooltip:
          AppLocalizations.of(context)?.changeLanguage ?? 'Change Language',
      onSelected: onLanguageChanged,
      itemBuilder: (context) => LanguageSelector._languages.map((language) {
        final locale = Locale(language['code']);
        final isSelected = locale.languageCode == currentLocale.languageCode;

        return PopupMenuItem<Locale>(
          value: locale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language['code'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
