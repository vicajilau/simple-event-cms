import 'package:flutter/material.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class OnLiveViewModel extends ViewModelCommon {

}

class OnLiveViewModelImpl extends OnLiveViewModel {
  @override
  String errorMessage = '';

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  void dispose() {

  }

  @override
  Future<void> setup([Object? argument]) {
    viewState.value = ViewState.loadFinished;
    return Future.value();
  }

}
