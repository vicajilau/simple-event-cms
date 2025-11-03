import 'package:flutter/material.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/organization_use_case.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/use_cases/check_token_saved_use_case.dart';
import '../../../view_model_common.dart';

abstract class OrganizationViewModel extends ViewModelCommon {
  Future<void> updateOrganization(Organization organization, BuildContext context);
}

class OrganizationViewModelImpl extends OrganizationViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();

  final OrganizationUseCase organizationUseCase = getIt<OrganizationUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<void> updateOrganization(Organization organization, BuildContext context) async {
    viewState.value = ViewState.isLoading;
    var result = await organizationUseCase.updateOrganization(organization);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        if(context.mounted){
          Navigator.pop(context, organization);
        }
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  void dispose() {}

  @override
  Future<void> setup([Object? argument]) async {}
}
