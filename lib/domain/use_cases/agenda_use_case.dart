import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class AgendaUseCase {
  Future<List<Agenda>> getComposedAgendas();
  Future<Agenda?> getAgendaById(String id);
  void saveAgenda(Agenda agenda);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<List<Agenda>> getComposedAgendas() {
    return repository.loadEAgendas();
  }

  @override
  Future<Agenda?> getAgendaById(String id) async {
    return await getComposedAgendas().then((agendas) {
      agendas.firstWhere((event) => event.uid == id);
      return null;
    });
  }

  @override
  void saveAgenda(Agenda agenda) {
    repository.saveAgenda(agenda);
  }

  @override
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId) {
    repository.saveAgendaDayById(agendaDay, agendaId);
  }
}
