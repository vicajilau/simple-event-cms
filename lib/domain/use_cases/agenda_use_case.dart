import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class AgendaUseCase {
  Future<Agenda?> getAgendaById(String id);
  void saveAgenda(Agenda agenda,String eventId);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void addSessionIntoAgenda(
      String agendaId,
      String agendaDayId,
      String trackId,
      Session session,
      );
  void editSession(Session session,String parentId);
  void deleteSessionFromAgendaDay(String sessionId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Agenda?> getAgendaById(String id) async {
    final agendas = await repository.loadEAgendas();
    return agendas.firstWhere((event) => event.uid == id);
  }

  @override
  void saveAgenda(Agenda agenda,String eventId) {
    repository.saveAgenda(agenda,eventId);
  }

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    repository.saveAgendaDayById(agendaDay, agendaId);
  }

  @override
  void addSessionIntoAgenda(
      String agendaId,
      String agendaDayId,
      String trackId,
      Session session,
      ) {
    repository.addSessionIntoAgenda(agendaId, agendaDayId, trackId,session);
  }

  @override
  void editSession(Session session,String parentId) {
    repository.editSession(session,parentId);
  }

  @override
  void deleteSessionFromAgendaDay(String sessionId) {
    repository.deleteSessionFromAgendaDay(sessionId);
  }
}

