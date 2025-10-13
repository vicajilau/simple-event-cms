import 'package:flutter/material.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/view_model_common.dart';

class ErrorView extends StatelessWidget {
  final ErrorType errorType;
  const ErrorView({super.key, required this.errorType});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    switch (errorType) {
      case ErrorType.none:
        return Text('');
      case ErrorType.errorLoadingData:
        return Text(localization?.errorLoadingData ?? '');
      case ErrorType.unknow:
        return Text(localization?.errorUnknown ?? '');
    }
  }
}
