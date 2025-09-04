import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum SessionType { keynote, talk, workshop, sessionBreak, panel, other }

abstract class SessionTypes {
  static Color getSessionTypeColor(BuildContext context, String type) {
    switch (type) {
      case 'keynote':
        return Colors.purple.shade100;
      case 'talk':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'workshop':
        return Colors.green.shade100;
      case 'sessionBreak':
        return Colors.orange.shade100;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  static Color getSessionTypeTextColor(BuildContext context, String type) {
    switch (type) {
      case 'keynote':
        return Colors.purple.shade800;
      case 'talk':
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case 'workshop':
        return Colors.green.shade800;
      case 'sessionBreak':
        return Colors.orange.shade800;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  static String getSessionTypeLabel(BuildContext context, String type) {
    switch (type) {
      case 'keynote':
        return AppLocalizations.of(context)!.keynote;
      case 'talk':
        return AppLocalizations.of(context)!.talk;
      case 'workshop':
        return AppLocalizations.of(context)!.workshop;
      case 'sessionBreak':
        return AppLocalizations.of(context)!.sessionBreak;
      case 'panel':
        return 'PANEL';
      case 'other':
        return 'other';
      default:
        return 'other';
    }
  }

  static List<String> allLabels(BuildContext context) {
    return SessionType.values
        .map((type) => getSessionTypeLabel(context, type.name))
        .toList();
  }
}
