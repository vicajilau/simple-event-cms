import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SponsorViewModel implements ViewModelCommon {
  abstract final ValueNotifier<List<Sponsor>> sponsors;
  void addSponsor(Sponsor sponsor, String parentId);
  void removeSponsor(String id);
}

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
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  ValueNotifier<List<Sponsor>> sponsors = ValueNotifier([]);

  @override
  void addSponsor(Sponsor sponsor, String parentId) async {
    sponsors.value.removeWhere((s) => s.uid == sponsor.uid);
    sponsors.value = [...sponsors.value, sponsor];
    sponsorUseCase.saveSponsor(sponsor, parentId);
  }

  @override
  void removeSponsor(String id) {
    List<Sponsor> currentSponsors = [...sponsors.value];
    currentSponsors.removeWhere((s) => s.uid == id);
    sponsors.value = currentSponsors;
    sponsorUseCase.removeSponsor(id);
  }

  @override
  void dispose() {
    viewState.dispose();
    sponsors.dispose();
  }

  @override
  void setup([Object? argument]) {
    if (argument is List<String>) {
      _loadSponsors(argument);
    }
  }

  Future<void> _loadSponsors(List<String> sponsorIds) async {
    viewState.value = ViewState.isLoading;
    final result = await sponsorUseCase.getSponsorByIds(sponsorIds);
    switch (result) {
      case Ok<List<Sponsor>>():
        sponsors.value = result.value;
        viewState.value = ViewState.loadFinished;
      case Error<List<Sponsor>>():
        // TODO: immplementación control de errores (hay que crear los errores)
        errorMessage = "Error cargando datos";
        viewState.value = ViewState.error;
    }
  }
}
