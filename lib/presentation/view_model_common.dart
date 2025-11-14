import 'package:flutter/foundation.dart';
import 'package:sec/data/exceptions/exceptions.dart';

enum ViewState { error, isLoading, loadFinished }

enum ErrorType { none, errorLoadingData, unknow }

abstract class ViewModelCommon {
  abstract final ValueNotifier<ViewState> viewState;
  abstract String errorMessage;

  Future<void> setup([Object? argument]);
  void dispose();
  Future<bool> checkToken();
  void setErrorKey(CustomException? exception) {
    if (exception != null) {
      errorMessage = exception.message;
    } else {
      errorMessage = "";
    }
  }
}
