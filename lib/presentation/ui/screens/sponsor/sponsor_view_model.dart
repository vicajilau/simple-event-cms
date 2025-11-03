import 'package:flutter/cupertino.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SponsorViewModel extends ViewModelCommon {
  abstract final ValueNotifier<List<Sponsor>> sponsors;
  Future<void> addSponsor(Sponsor sponsor, String parentId);
  Future<void> removeSponsor(String id);
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
  Future<void> addSponsor(Sponsor sponsor, String parentId) async {
    sponsors.value.removeWhere((s) => s.uid == sponsor.uid);
    sponsors.value = [...sponsors.value, sponsor];
    final result = await sponsorUseCase.saveSponsor(sponsor, parentId);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
      case Error<void>():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  Future<void> removeSponsor(String id) async {
    List<Sponsor> currentSponsors = [...sponsors.value];
    currentSponsors.removeWhere((s) => s.uid == id);
    sponsors.value = currentSponsors;
    final result = await sponsorUseCase.removeSponsor(id);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
      case Error<void>():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }

  @override
  void dispose() {
    viewState.dispose();
    sponsors.dispose();
  }

  @override
  Future<void> setup([Object? argument]) async {
    if (argument is String) {
      _loadSponsors(argument);
    }
  }

  Future<void> _loadSponsors(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await sponsorUseCase.getSponsorByIds(eventId);
    switch (result) {
      case Ok<List<Sponsor>>():
        sponsors.value = result.value;
        viewState.value = ViewState.loadFinished;
      case Error<List<Sponsor>>():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
    }
  }
}
