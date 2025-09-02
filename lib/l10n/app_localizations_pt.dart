// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loadingAgenda => 'Carregando agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Erro ao carregar agenda: $error';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noEventsScheduled => 'Nenhum evento agendado';

  @override
  String get loadingSpeakers => 'Carregando palestrantes...';

  @override
  String get errorLoadingSpeakers => 'Erro ao carregar palestrantes';

  @override
  String get noSpeakersRegistered => 'Nenhum palestrante registrado';

  @override
  String get loadingSponsors => 'Carregando patrocinadores...';

  @override
  String get errorLoadingSponsors => 'Erro ao carregar patrocinadores';

  @override
  String get noSponsorsRegistered => 'Nenhum patrocinador registrado';

  @override
  String get loading => 'Carregando...';

  @override
  String get errorLoadingImage => 'Erro ao carregar imagem';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'PALESTRA';

  @override
  String get workshop => 'WORKSHOP';

  @override
  String get sessionBreak => 'INTERVALO';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Palestrantes';

  @override
  String get sponsors => 'Patrocinadores';

  @override
  String get eventInfo => 'Informações do Evento';

  @override
  String get eventDates => 'Datas do Evento';

  @override
  String get venue => 'Local';

  @override
  String get description => 'Descrição';

  @override
  String get close => 'Fechar';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Site';

  @override
  String get openUrl => 'Abrir URL';

  @override
  String get changeLanguage => 'Alterar Idioma';
}
