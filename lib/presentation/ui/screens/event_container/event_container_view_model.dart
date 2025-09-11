import 'package:sec/core/models/models.dart';
import 'package:uuid/uuid.dart';

abstract class EventContainerViewModel {
  Agenda getAgenda();
  List<Speaker> getSpeakers();
  List<Sponsor> getSponsors();
  void addSponsor(Sponsor sponsor);
}

class EventContainerViewModelImp extends EventContainerViewModel {
  final Event event;

  EventContainerViewModelImp({required this.event});

  @override
  Agenda getAgenda() {
    return event.agenda ?? _createNewAgenda();
  }

  Agenda _createNewAgenda() {
    final List<Track> tracks = event.tracks
        .map((e) => Track(name: e, color: '', sessions: []))
        .toList();
    final List<AgendaDay> agendaDays = event.eventDates
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
    return event.speakers ?? [];
  }

  @override
  List<Sponsor> getSponsors() {
    return event.sponsors ?? [];
  }

  @override
  void addSponsor(Sponsor sponsor) async {
    /* final newSponsor = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSponsorScreen()),
    );*/

    /*if (sponsor != null && newSponsor is Sponsor) {
      setState(() {*/
    event.sponsors?.add(sponsor);
    /*   _screens[2] = SponsorsScreen(key: UniqueKey(), sponsors: _sponsors);
      });*/
  }
}
