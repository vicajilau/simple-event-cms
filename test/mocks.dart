
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:sec/core/config/secure_info.dart';
import 'package:sec/core/models/config.dart';
import 'package:sec/core/models/event_dates.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
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
  CommonsServices,
  DataLoaderManager,
  DataUpdateManager,
  AgendaViewModel,
  AgendaFormData,
  AgendaUseCase,
  ConfigViewModel,
  SecRepository,
  EventDetailViewModel,
  TokenRepository,
  ConfigUseCase,
  OnLiveViewModel,
  EventUseCase,
  CheckOrg,
  EventCollectionViewModel,
  GoRouter,
  Config,
  Social,
  SecureInfo,
  SpeakerUseCase,
  SponsorViewModel,
  SponsorUseCase,
  SpeakerViewModel,
  EventFormViewModel,
  AgendaFormViewModel,
  CheckTokenSavedUseCase,
  EventDates,
])
void main() {}
