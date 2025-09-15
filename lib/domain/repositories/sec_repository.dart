import 'package:sec/core/models/models.dart';

abstract class SecRepository {
  Future<List<Event>> loadEvents();
  Future<List<Agenda>> loadEAgendas();
  Future<List<Speaker>> loadESpeakers();
  Future<List<Sponsor>> loadSponsors();
  Future<void> saveEvent(Event event);
}
