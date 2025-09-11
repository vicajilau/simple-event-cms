import 'package:sec/core/models/models.dart';
import 'package:sec/data/local_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

class SecRepositoryImp extends SecRepository {
  final DataLoader dataLoader;

  SecRepositoryImp({required this.dataLoader});

  @override
  Future<List<Event>> loadEvents() async {
    return dataLoader.config;
  }

  @override
  Future<List<Agenda>> loadEAgendas() async {
    return await dataLoader.loadAgenda("2025");
  }

  @override
  Future<List<Speaker>> loadESpeakers() async {
    return await dataLoader.loadSpeakers("2025");
  }

  @override
  Future<List<Sponsor>> loadSponsors() async {
    return await dataLoader.loadSponsors("2025");
  }

  @override
  Future<void> saveEvents(List<Event> events) {
    // TODO: implement saveEvents
    throw UnimplementedError();
  }
}
