import 'dart:io';

import 'package:github/github.dart' hide Event;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/agenda.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/models/event.dart';
import 'package:sec/core/models/event_dates.dart';
import 'package:sec/core/models/github/github_data.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/common/data_manager.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/domain/repositories/token_repository.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/domain/use_cases/event_use_case.dart';
import 'package:sec/domain/use_cases/speaker_use_case.dart';
import 'package:sec/domain/use_cases/sponsor_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_screen.dart';
import 'package:sec/presentation/ui/screens/agenda/form/agenda_form_view_model.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/event_form/event_form_view_model.dart';
import 'package:sec/presentation/ui/screens/on_live/on_live_view_model.dart';
import 'package:sec/presentation/ui/screens/speaker/speaker_view_model.dart';
import 'package:sec/presentation/ui/screens/sponsor/sponsor_view_model.dart';

@GenerateMocks([
  AgendaDay,
  AgendaFormData,
  AgendaFormViewModel,
  AgendaViewModel,
  AgendaUseCase,
  CheckOrg,
  CheckTokenSavedUseCase,
  Client,
  CommonsServices,
  CommonsServicesImp,
  Config,
  ConfigViewModel,
  ContentCreation,
  ConfigUseCase,
  DataLoaderManager,
  DataUpdateManager,
  DataUpdate,
  Event,
  EventCollectionViewModel,
  EventDates,
  EventDetailViewModel,
  EventFormViewModel,
  EventUseCase,
  GitHub,
  GithubData,
  GitHubFile,
  GoRouter,
  HttpClient,
  OnLiveViewModel,
  RepositoriesService,
  RepositoryContents,
  SecRepository,
  SecureInfo,
  Social,
  Speaker,
  SpeakerViewModel,
  SpeakerUseCase,
  SponsorUseCase,
  SponsorViewModel,
  Track,
  TokenRepository,
  Nominatim,
])
void main() {}
