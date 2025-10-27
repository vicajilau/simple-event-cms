import 'package:flutter/material.dart';
import 'package:sec/l10n/app_localizations.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;
  const ErrorView({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    switch (errorMessage) {
      case '':
        return Text(localization?.errorLoadingData ?? '');
      default:
        return Text(errorMessage);
    }
  }
}
