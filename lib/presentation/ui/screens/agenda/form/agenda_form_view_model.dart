import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<List<Track>?> getTracksByEventId(String eventId);

  Future<void> updateTrack(Track track, String agendaDayId);

  Future<void> removeTrack(String trackID, {var overrideTrack = false});

  Future<void> updateAgendaDay(AgendaDay agendaDay, String eventUID);

  Future<List<Speaker>> getSpeakersForEventId(String eventId);

  Future<void> addSession(Session session, String trackUID);

  Future<void> addSpeaker(String eventId, Speaker speaker);

  Future<bool> addTrack(Track track, String agendaDayId);

  Future<void> updateEvent(Event event);

  Future<List<AgendaDay>?> saveSession(
    BuildContext context,
    String? sessionUid,
    String title,
    TimeOfDay? initSessionTime,
    TimeOfDay? endSessionTime,
    Speaker selectedSpeaker,
    String description,
    String selectedTalkType,
    String eventId,
    String selectedDay,
    List<Track> tracks,
    String selectedTrackUid,
    String? oldTrackId,
    List<AgendaDay> agendaDays,
  );
}

class AgendaFormViewModelImpl extends AgendaFormViewModel {
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
  final AgendaUseCase agendaUseCase = getIt<AgendaUseCase>();

  @override
  String errorMessage = '';

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }

  @override
  Future<void> addSession(Session session, String trackUID) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.addSession(session, trackUID);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<List<Speaker>> getSpeakersForEventId(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getSpeakersForEventId(eventId);
    switch (result) {
      case Ok<List<Speaker>>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return [];
    }
  }

  @override
  Future<Track?> getTrackById(String trackId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getTrackById(trackId);
    switch (result) {
      case Ok<Track>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return null;
    }
  }

  @override
  Future<AgendaDay?> getAgendaDayById(String agendaDayId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getAgendaDayById(agendaDayId);
    switch (result) {
      case Ok<AgendaDay>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
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
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getAgendaDayByEventId(eventId);
    switch (result) {
      case Ok<List<AgendaDay>>():
        final days = List<AgendaDay>.from(result.value)
          ..sort((a, b) => a.date.compareTo(b.date)); 
        viewState.value = ViewState.loadFinished;
        return days;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return null;
    }
  }

  @override
  Future<List<Track>?> getTracksByEventId(String eventId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.getTracksByEventId(eventId);
    switch (result) {
      case Ok<List<Track>>():
        viewState.value = ViewState.loadFinished;
        return result.value;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return null;
    }
  }

  @override
  Future<Event?> getEventById(String eventId) async {
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
  Future<void> addSpeaker(String eventId, Speaker speaker) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.addSpeaker(eventId, speaker);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.saveEvent(event);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<void> updateTrack(Track track, String agendaDayId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.updateTrack(track, agendaDayId);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<void> updateAgendaDay(AgendaDay agendaDay, String eventUID) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.updateAgendaDay(agendaDay, eventUID);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<bool> addTrack(Track track, String agendaDayId) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.updateTrack(track, agendaDayId);
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
  Future<void> setup([Object? argument]) {
    return Future.value();
  }

  @override
  Future<void> removeTrack(String trackID, {var overrideTrack = false}) async {
    viewState.value = ViewState.isLoading;
    final result = await agendaUseCase.removeTrack(trackID);
    switch (result) {
      case Ok<void>():
        viewState.value = ViewState.loadFinished;
        return;
      case Error():
        setErrorKey(result.error);
        viewState.value = ViewState.error;
        return;
    }
  }

  @override
  Future<List<AgendaDay>?> saveSession(
    BuildContext context,
    String? sessionUid,
    String title,
    TimeOfDay? initSessionTime,
    TimeOfDay? endSessionTime,
    Speaker selectedSpeaker,
    String description,
    String selectedTalkType,
    String eventId,
    String selectedDay,
    List<Track> tracks,
    String selectedTrackUid,
    String? oldTrackId,
    List<AgendaDay> agendaDays,
  ) async {
    Session session = Session(
      uid:
          sessionUid ??
          'Session_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      title: title,
      time:
          '${initSessionTime!.format(context)} - ${endSessionTime!.format(context)}',
      speakerUID: selectedSpeaker.uid.toString(),
      description: description,
      type: selectedTalkType,
      eventUID: eventId,
      agendaDayUID: selectedDay,
    );

    await addSession(session, selectedTrackUid);

    viewState.value = ViewState.loadFinished;
    var containsAgendaDays = agendaDays.indexWhere(
      (day) => day.trackUids != null && day.trackUids!.isNotEmpty,
    );
    if (containsAgendaDays != -1) {
      return agendaDays
          .where((day) => day.trackUids != null && day.trackUids!.isNotEmpty)
          .toList();
    } else {
      return null;
    }
  }
}
