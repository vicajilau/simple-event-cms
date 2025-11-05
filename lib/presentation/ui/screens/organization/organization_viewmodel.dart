import 'package:flutter/material.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/organization_use_case.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/use_cases/check_token_saved_use_case.dart';
import '../../../view_model_common.dart';

abstract class OrganizationViewModel extends ViewModelCommon {
  /// return true if update was OK, false if there was an error.
  Future<bool> updateOrganization(Organization organization);
}

class OrganizationViewModelImpl extends OrganizationViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final OrganizationUseCase organizationUseCase = getIt<OrganizationUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.loadFinished); 

  @override
  String errorMessage = '';

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<bool> updateOrganization(Organization organization) async {
    viewState.value = ViewState.isLoading;

    final result = await organizationUseCase.updateOrganization(organization);

    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return true;

      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return false;
    }
  }

  @override
  void dispose() {}

  @override
  Future<void> setup([Object? argument]) async {}
}
