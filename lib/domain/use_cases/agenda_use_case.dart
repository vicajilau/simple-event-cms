import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/result.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class AgendaUseCase {
  Future<Result<Agenda?>> getAgendaById(String id);
  void saveAgenda(Agenda agenda, String eventId);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
  void addSessionIntoAgenda(
    String agendaId,
    String agendaDayId,
    String trackId,
    Session session,
  );
  void editSession(Session session, String parentId);
  void deleteSessionFromAgendaDay(String sessionId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Result<Agenda?>> getAgendaById(String id) async {
    final result = await repository.loadEAgendas();
    switch (result) {
      case Ok<List<Agenda>>():
        return Result.ok(result.value.firstWhere((event) => event.uid == id));
      case Error():
        return Result.error(result.error);
    }
  }

  @override
  void saveAgenda(Agenda agenda, String eventId) {
    repository.saveAgenda(agenda, eventId);
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
    repository.addSessionIntoAgenda(agendaId, agendaDayId, trackId, session);
  }

  @override
  void editSession(Session session, String parentId) {
    repository.editSession(session, parentId);
  }

  @override
  void deleteSessionFromAgendaDay(String sessionId) {
    repository.deleteSessionFromAgendaDay(sessionId);
  }
}

