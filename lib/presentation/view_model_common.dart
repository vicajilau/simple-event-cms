import 'package:flutter/foundation.dart';

enum ViewState { error, isLoading, loadFinished }

abstract class ViewModelCommon {
  abstract final ValueNotifier<ViewState> viewState;
  abstract final String errorMessage;

  void setup([Object? argument]);
  void dispose();
  Future<bool> checkToken();
}
