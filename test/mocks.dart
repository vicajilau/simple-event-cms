import 'package:mockito/annotations.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/data/remote_data/common/commons_api_services.dart';
import 'package:sec/data/remote_data/load_data/data_loader.dart';
import 'package:sec/data/remote_data/update_data/data_update.dart';
import 'package:sec/domain/use_cases/agenda_use_case.dart';
import 'package:sec/domain/use_cases/check_token_saved_use_case.dart';
import 'package:sec/domain/use_cases/config_use_case.dart';
import 'package:sec/presentation/ui/screens/agenda/agenda_view_model.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';

@GenerateMocks([
  CommonsServices,
  DataLoader,
  DataUpdateInfo,
  AgendaViewModel,
  AgendaUseCase,
  ConfigViewModel,
  ConfigUseCase,
  CheckOrg,
  CheckTokenSavedUseCase,
])
void main() {}
