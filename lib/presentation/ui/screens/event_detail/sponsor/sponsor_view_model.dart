import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SponsorViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<Sponsor>> sponsors;
  void addSponsor(Sponsor sponsor);
  void editSponsor(Sponsor sponsor);
  void removeSponsor(String id);
}

// Concrete SponsorViewModelImpl (similar to AgendaViewModelImp)
class SponsorViewModelImpl extends SponsorViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final SponsorUseCase sponsorUseCase = getIt<SponsorUseCase>();

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  Future<bool> checkToken() async {
    // This is based on your AgendaViewModelImp:
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  ValueNotifier<List<Sponsor>> sponsors = ValueNotifier([]);

  @override
  void addSponsor(Sponsor sponsor) async {
    sponsorUseCase.saveSponsor(sponsor);
  }

  @override
  void editSponsor(Sponsor sponsor) {
    sponsorUseCase.saveSponsor(sponsor);
  }

  @override
  void removeSponsor(String id) {
    sponsorUseCase.removeSponsor(id);
  }

  @override
  void dispose() {
    // Add any specific disposal logic for SponsorViewModel here
  }

  @override
  void setup([Object? argument]) {
    // Add any specific setup logic for SponsorViewModel here
  }
}
