import 'package:flutter/foundation.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:uuid/uuid.dart';

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
  final EventUseCase useCase;
  final String eventId;
  Event? event;

  @override
  ValueNotifier<ViewState> viewState = ValueNotifier(ViewState.isLoading);

  @override
  String errorMessage = '';

  @override
  Agenda getAgenda() {
    return event?.agenda ?? _createNewAgenda();
  }

  EventDetailViewModelImp(this.useCase, this.eventId);

  @override
  void dispose() {
    viewState.dispose();
  }

  @override
  void setup() {
    _loadEventData(eventId);
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
    final List<AgendaDay> agendaDays = event!.eventDates
        .getFormattedDaysInDateRange()
        .map((e) {
          return AgendaDay(date: e, tracks: tracks);
        })
        .toList();
    return Agenda(
      days: agendaDays,
      uid: Uuid().v1(),
      pathUrl: '',
      updateMessage: '',
    );
  }

  @override
  ValueNotifier<List<Sponsor>> sponsors = ValueNotifier([]);

  @override
  void addSponsor(Sponsor sponsor) async {
    List<Sponsor> currentSponsors = [...event?.sponsors ?? []];
    currentSponsors.add(sponsor);
    sponsors.value = currentSponsors;
    // TODO: llamar al use case para que guarde
  }

  @override
  void editSponsor(Sponsor sponsor) {
    final index =
        event?.sponsors?.indexWhere((s) => s.uid == sponsor.uid) ?? -1;
    List<Sponsor> currentSponsors = [...event?.sponsors ?? []];
    if (index != -1) {
      currentSponsors[index] = sponsor;
      sponsors.value = currentSponsors;
      // TODO: llamar al use case para que guarde
    }
  }

  @override
  void removeSponsor(String id) {
    List<Sponsor> currentSponsors = [...event?.sponsors ?? []];
    currentSponsors.removeWhere((s) => s.uid == id);
    sponsors.value = currentSponsors;
    // TODO: llamar al use case para que guarde
  }

  @override
  ValueNotifier<List<Speaker>> speakers = ValueNotifier([]);

  @override
  void addSpeaker(Speaker speaker) {
    List<Speaker> currentSpeakers = [...event?.speakers ?? []];
    currentSpeakers.add(speaker);
    speakers.value = currentSpeakers;
    // TODO: llamar al use case para que guarde
  }

  @override
  void editSpeaker(Speaker speaker) {
    final index =
        event?.speakers?.indexWhere((s) => s.uid == speaker.uid) ?? -1;
    List<Speaker> currentSpeakers = [...event?.speakers ?? []];
    if (index != -1) {
      currentSpeakers[index] = speaker;
      speakers.value = currentSpeakers;
      // TODO: llamar al use case para que guarde
    }
  }

  @override
  void removeSpeaker(String id) {
    List<Speaker> currentSpeakers = [...event?.speakers ?? []];
    currentSpeakers.removeWhere((s) => s.uid == id);
    speakers.value = currentSpeakers;
    // TODO: llamar al use case para que guarde
  }
}
