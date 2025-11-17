import 'package:flutter/material.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/use_cases/check_token_saved_use_case.dart';

abstract class OnLiveViewModel extends ViewModelCommon {}

class OnLiveViewModelImpl extends OnLiveViewModel {
  @override
  String errorMessage = '';

  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  void dispose() {}
  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<void> setup([Object? argument]) {
    viewState.value = ViewState.loadFinished;
    return Future.value();
  }
}
