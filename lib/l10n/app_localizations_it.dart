// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get loadingAgenda => 'Caricamento agenda...';

  @override
  String errorLoadingAgenda(String error) {
    return 'Errore durante il caricamento dell\'agenda: $error';
  }

  @override
  String get retry => 'Riprova';

  @override
  String get noEventsScheduled => 'Nessun evento programmato';

  @override
  String get loadingSpeakers => 'Caricamento relatori...';

  @override
  String get errorLoadingSpeakers =>
      'Errore durante il caricamento dei relatori';

  @override
  String get noSpeakersRegistered => 'Nessun relatore registrato';

  @override
  String get loadingSponsors => 'Caricamento sponsor...';

  @override
  String get errorLoadingSponsors =>
      'Errore durante il caricamento degli sponsor';

  @override
  String get noSponsorsRegistered => 'Nessuno sponsor registrato';

  @override
  String get loading => 'Caricamento...';

  @override
  String get errorLoadingImage =>
      'Errore durante il caricamento dell\'immagine';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'PRESENTAZIONE';

  @override
  String get workshop => 'WORKSHOP';

  @override
  String get sessionBreak => 'PAUSA';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Relatori';

  @override
  String get sponsors => 'Sponsor';

  @override
  String get eventInfo => 'Informazioni sull\'Evento';

  @override
  String get eventDates => 'Date dell\'Evento';

  @override
  String get venue => 'Luogo';

  @override
  String get description => 'Descrizione';

  @override
  String get close => 'Chiudi';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Sito Web';

  @override
  String get openUrl => 'Apri URL';

  @override
  String get changeLanguage => 'Cambia Lingua';

  @override
  String get speakerForm => 'Modulo del Relatore';

  @override
  String get nameLabel => 'Nome*';

  @override
  String get nameErrorHint => 'Per favore inserisci il tuo nome';

  @override
  String get bioLabel => 'Biografia*';

  @override
  String get bioErrorHint => 'Per favore inserisci la tua biografia';

  @override
  String get imageUrlLabel => 'URL dell\'immagine';

  @override
  String get nameHint => 'Inserisci il nome del relatore';

  @override
  String get bioHint => 'Inserisci la biografia del relatore';

  @override
  String get imageUrlHint => 'Inserisci l\'URL dell\'immagine del relatore';

  @override
  String get twitterHint => 'Inserisci l\'URL di Twitter';

  @override
  String get githubHint => 'Inserisci l\'URL di GitHub';

  @override
  String get linkedinHint => 'Inserisci l\'URL di LinkedIn';

  @override
  String get websiteHint => 'Inserisci l\'URL del sito web';

  @override
  String get saveButton => 'Salva';
}
