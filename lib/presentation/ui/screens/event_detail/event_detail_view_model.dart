import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class SponsorsViewModel {
  abstract final ValueNotifier<List<Sponsor>> sponsors;
  void addSponsor(Sponsor sponsor);
  void editSponsor(Sponsor sponsor);
  void removeSponsor(String id);
}

abstract class SpeakersViewModel {
  abstract final ValueNotifier<List<Speaker>> speakers;
  void addSpeaker(Speaker speaker);
  void editSpeaker(Speaker speaker);
  void removeSpeaker(String id);
}

abstract class EventDetailViewModel
    implements ViewModelCommon, SponsorsViewModel, SpeakersViewModel {
  String eventTitle();
  Agenda getAgenda();
}

class EventDetailViewModelImp extends EventDetailViewModel {
  final EventUseCase useCase = getIt<EventUseCase>();
  final SpeakerUseCase speakerUseCase = getIt<SpeakerUseCase>();
  final SponsorUseCase sponsorUseCase = getIt<SponsorUseCase>();
  Event? event;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  Agenda getAgenda() {
    return event?.agenda ?? _createNewAgenda();
  }

  @override
  void dispose() {}

  @override
  void setup([Object? argument]) {
    if (argument is String) {
      _loadEventData(argument);
    }
  }

  @override
  String eventTitle() {
    return event?.eventName ?? '';
  }

  Future<void> _loadEventData(String eventId) async {
    try {
      viewState.value = ViewState.isLoading;
      final events = await useCase.getComposedEvents();

      event = events.firstWhere(
        (e) => e.uid == eventId,
        orElse: () => events.first, // Fallback al primer evento
      );
      sponsors.value = event?.sponsors ?? [];
      speakers.value = event?.speakers ?? [];
      viewState.value = ViewState.loadFinished;
    } catch (e) {
      // TODO: immplementación control de errores (hay que crear los errores)
      errorMessage = "Error cargando datos";
      viewState.value = ViewState.error;
    }
  }

  Agenda _createNewAgenda() {
    final List<Track> tracks = event!.tracks
        .map((e) => Track(name: e, color: '', sessions: []))
        .toList();
    final List<AgendaDay>
    agendaDays = event!.eventDates.getFormattedDaysInDateRange().map((e) {
      return AgendaDay(
        uid:
            'AgendaDay_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
        date: e,
        tracks: tracks,
      );
    }).toList();
    return Agenda(
      days: agendaDays,
      uid: 'Agenda_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
      pathUrl: '',
      updateMessage: '',
    );
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
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  void addSpeaker(Speaker speaker) {
    speakerUseCase.saveSpeaker(speaker);
  }

  @override
  void editSpeaker(Speaker speaker) {
    speakerUseCase.saveSpeaker(speaker);
  }

  @override
  void removeSpeaker(String id) {
    speakerUseCase.removeSpeaker(id);
  }
}
