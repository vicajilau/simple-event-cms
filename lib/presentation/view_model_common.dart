import 'package:flutter/foundation.dart';
import 'package:sec/data/exceptions/exceptions.dart';

enum ViewState { error, isLoading, loadFinished }

enum ErrorType { none, errorLoadingData, unknow }

abstract class ViewModelCommon {
  abstract final ValueNotifier<ViewState> viewState;
  abstract ErrorType errorType;

  void setup([Object? argument]);
  void dispose();
  Future<bool> checkToken();
  void setErrorKey(Exception exception) {
    errorType = switch (exception) {
      JsonDecodeException() ||
      GithubException() ||
      NetworkException() => ErrorType.errorLoadingData,
      _ => ErrorType.unknow,
    };
  }
}
