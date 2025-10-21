import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../../core/utils/result.dart';

abstract class AgendaFormViewModel extends ViewModelCommon {
  Future<Event?> loadEvent(String eventId);
  Future<Event?> getEventById(String eventId);
  Future<Track?> getTrackById(String trackId);
  Future<AgendaDay?> getAgendaDayById(String agendaDayId);
  Future<List<AgendaDay>?> getAgendaDayByEventId(String eventId);
  Future<List<Track>?> getTracks();
  Future<void> updateTrack(Track track, String agendaDayId);
  Future<void> updateAgendaDay(AgendaDay agendaDay, String eventUID);
  Future<List<Speaker>> getSpeakersForEventId(String eventId);
  Future<void> addSession(Session session, String trackUID);
  Future<void> addSpeaker(String eventId, Speaker speaker);
  Future<void> addTrack(Track track,String agendaDayId);
  Future<void> updateEvent(Event event);
}

class AgendaFormViewModelImpl extends AgendaFormViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final AgendaUseCase agendaUseCase = getIt<AgendaUseCase>();

  @override
  ErrorType errorType = ErrorType.none;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  void setup([Object? argument]) {
    if (argument is String) {}
  }

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<void> addSession(Session session, String trackUID) async {
    await agendaUseCase.addSession(session, trackUID);
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    final result = await agendaUseCase.getSpeakersForEventId(eventId);
    switch (result) {
      case Ok<List<Speaker>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return [];
    }
  }

  @override
  Future<Track?> getTrackById(String trackId) async {
    final result = await agendaUseCase.getTrackById(trackId);
    switch (result) {
      case Ok<Track>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<AgendaDay?> getAgendaDayById(String agendaDayId) async {
    final result = await agendaUseCase.getAgendaDayById(agendaDayId);
    switch (result) {
      case Ok<AgendaDay>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  void dispose() {}

  @override
  Future<Event?> loadEvent(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.loadEvent(eventId);

    switch (result) {
      case Ok<Event>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return null;
    }
  }

  @override
  Future<List<AgendaDay>?> getAgendaDayByEventId(String eventId) async {
    final result = await agendaUseCase.getAgendaDayByEventId(eventId);
    switch (result) {
      case Ok<List<AgendaDay>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<List<Track>?> getTracks() async {
    final result = await agendaUseCase.getTracks();
    switch (result) {
      case Ok<List<Track>>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    final result = await agendaUseCase.loadEvent(eventId);
    switch (result) {
      case Ok<Event>():
        return result.value;
      case Error():
        setErrorKey(result.error);
        return null;
    }
  }

  @override
  Future<void> addSpeaker(String eventId, Speaker speaker) async {
    await agendaUseCase.addSpeaker(eventId, speaker);
  }

  @override
  Future<void> updateEvent(Event event) async {
    await agendaUseCase.saveEvent(event);
  }

  @override
  Future<void> updateTrack(Track track, String agendaDayId) async {
    await agendaUseCase.updateTrack(track, agendaDayId);
  }

  @override
  Future<void> updateAgendaDay(AgendaDay agendaDay, String eventUID) async {
    await agendaUseCase.updateAgendaDay(agendaDay,eventUID);
  }

  @override
  Future<void> addTrack(Track track,String agendaDayId) async {
    await agendaUseCase.updateTrack(track,agendaDayId);
  }
}
