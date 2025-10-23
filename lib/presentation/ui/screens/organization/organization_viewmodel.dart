import 'package:flutter/material.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/organization_use_case.dart';

import '../../../../core/di/dependency_injection.dart';
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
  ErrorType errorType = ErrorType.none;

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<void> updateOrganization(Organization organization, BuildContext context) async {
    viewState.value = ViewState.isLoading;
    await organizationUseCase.updateOrganization(organization);
    viewState.value = ViewState.loadFinished;
    if(context.mounted){
      Navigator.pop(context, organization);
    }
  }

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {}
}
