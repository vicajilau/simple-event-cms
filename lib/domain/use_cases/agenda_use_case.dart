import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

abstract class AgendaUseCase {
  Future<Agenda?> getAgendaById(String id);
  void saveAgenda(Agenda agenda);
  void saveAgendaDayById(AgendaDay agendaDay, String agendaId);
}

class AgendaUseCaseImpl implements AgendaUseCase {
  final SecRepository repository = getIt<SecRepository>();

  @override
  Future<Agenda?> getAgendaById(String id) async {
    final agendas = await repository.loadEAgendas();
    return agendas.firstWhere((event) => event.uid == id);
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
