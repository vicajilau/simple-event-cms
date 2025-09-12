import 'package:flutter/foundation.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/view_model_common.dart';
import 'package:uuid/uuid.dart';

abstract class EventDetailViewModel extends ViewModelCommon {
  String eventTitle();
  Agenda getAgenda();
  List<Speaker> getSpeakers();
  List<Sponsor> getSponsors();
  void addSponsor(Sponsor sponsor);
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
  List<Speaker> getSpeakers() {
    return event?.speakers ?? [];
  }

  @override
  List<Sponsor> getSponsors() {
    return event?.sponsors ?? [];
  }

  @override
  void addSponsor(Sponsor sponsor) async {
    /* final newSponsor = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSponsorScreen()),
    );*/

    /*if (sponsor != null && newSponsor is Sponsor) {
      setState(() {*/
    event!.sponsors?.add(sponsor);
    /*   _screens[2] = SponsorsScreen(key: UniqueKey(), sponsors: _sponsors);
      });*/
  }
}
