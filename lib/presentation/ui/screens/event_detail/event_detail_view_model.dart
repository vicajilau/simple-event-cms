import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/view_model_common.dart';

abstract class EventDetailViewModel implements ViewModelCommon {
  String eventTitle();
  Agenda getAgenda();
}

class EventDetailViewModelImp extends EventDetailViewModel {
  final EventUseCase useCase = getIt<EventUseCase>();
  final SpeakerViewModel speakerViewModel = getIt<SpeakerViewModel>();
  final SponsorViewModel sponsorViewModel = getIt<SponsorViewModel>();
  final CheckTokenSavedUseCase checkTokenSavedUseCase =
      getIt<CheckTokenSavedUseCase>();
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
      sponsorViewModel.sponsors.value = event?.sponsors ?? [];
      speakerViewModel.speakers.value = event?.speakers ?? [];
      viewState.value = ViewState.loadFinished;
    } catch (e) {
      // TODO: immplementación control de errores (hay que crear los errores)
      errorMessage = "Error cargando datos";
      viewState.value = ViewState.error;
    }
  }

  Agenda _createNewAgenda() {
    final List<Track> tracks = event!.tracks
        .map(
          (e) => Track(
            uid:
                'Track_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
            name: e,
            color: '',
            sessions: [],
          ),
        )
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
  Future<bool> checkToken() async {
    return await checkTokenSavedUseCase.checkToken();
  }
}
