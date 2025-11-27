// NEW
import 'package:flutter/foundation.dart';

class CheckOrg {
  final ValueListenable<bool> hasErrorListenable;
  bool get hasError => _hasError.value;

  final ValueNotifier<bool> _hasError;

  CheckOrg({bool initial = false})
    : _hasError = ValueNotifier(initial),
      hasErrorListenable = ValueNotifier(initial);

  void setError(bool v) {
    _hasError.value = v;
    (hasErrorListenable as ValueNotifier<bool>).value = v;
  }
}
