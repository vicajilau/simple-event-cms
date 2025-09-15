import 'package:sec/core/models/models.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/domain/repositories/sec_repository.dart';

import '../../core/config/secure_info.dart';
import '../remote_data/common/commons_services.dart';
import '../remote_data/update_data/data_update_info.dart';

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
  Future<void> saveEvent(Event event) async {
    var github = await SecureInfo.getGithubKey();
    if(github != null){
      DataUpdateInfo dataUpdateInfo = DataUpdateInfo(dataCommons: CommonsServices(githubService: github));
      await dataUpdateInfo.updateEvent(event);
    }
  }
}
