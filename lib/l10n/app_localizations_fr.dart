// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loadingAgenda => 'Chargement de l\'agenda...';

  @override
  String get retry => 'Réessayer';

  @override
  String get noEventsScheduled => 'Aucun événement programmé';

  @override
  String get loadingSpeakers => 'Chargement des intervenants...';

  @override
  String get noSpeakersRegistered => 'Aucun intervenant enregistré';

  @override
  String get loadingSponsors => 'Chargement des sponsors...';

  @override
  String get noSponsorsRegistered => 'Aucun sponsor enregistré';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorLoadingImage => 'Erreur lors du chargement de l\'image';

  @override
  String get keynote => 'KEYNOTE';

  @override
  String get talk => 'CONFÉRENCE';

  @override
  String get workshop => 'ATELIER';

  @override
  String get sessionBreak => 'PAUSE';

  @override
  String get agenda => 'Agenda';

  @override
  String get speakers => 'Intervenants';

  @override
  String get sponsors => 'Sponsors';

  @override
  String get nextEvent => 'Événement à venir...';

  @override
  String get eventInfo => 'Informations sur l\'Événement';

  @override
  String get eventDates => 'Dates de l\'Événement';

  @override
  String get venue => 'Lieu';

  @override
  String get visibilityLabel => 'Visibilité';

  @override
  String get eventIsOpenByDefault => 'L\'événement est ouvert par défaut';

  @override
  String get eventIsNotOpenByDefault =>
      'L\'événement n\'est pas ouvert par défaut';

  @override
  String get openByDefaultLabel => 'Ouvert par défaut';

  @override
  String get eventIsVisible => 'L\'événement est visible';

  @override
  String get changeVisibilityTitle => 'Changer la visibilité';

  @override
  String get changeVisibilityToHidden =>
      'Cela rendra l\'événement non visible pour les utilisateurs';

  @override
  String get changeVisibilityToVisible =>
      'À partir de maintenant, l\'événement sera visible pour tout le monde';

  @override
  String get eventIsHidden => 'L\'événement est masqué';

  @override
  String get description => 'Description';

  @override
  String get close => 'Fermer';

  @override
  String get twitter => 'Twitter/X';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get github => 'GitHub';

  @override
  String get website => 'Site Web';

  @override
  String get openUrl => 'Ouvrir l\'URL';

  @override
  String get changeLanguage => 'Changer la Langue';

  @override
  String get deleteEventTitle => 'Supprimer l\'événement';

  @override
  String get deleteEventMessage =>
      'Êtes-vous sûr de vouloir supprimer cet événement ? \n Cela supprimera les sessions associées à l\'événement.';

  @override
  String get speakerForm => 'Formulaire d\'intervenant';

  @override
  String get nameLabel => 'Nom*';

  @override
  String get nameErrorHint => 'Veuillez entrer votre nom';

  @override
  String get bioLabel => 'Biographie*';

  @override
  String get bioErrorHint => 'Veuillez entrer votre biographie';

  @override
  String get imageUrlLabel => 'URL de l\'image';

  @override
  String get nameHint => 'Entrez le nom de l\'intervenant';

  @override
  String get bioHint => 'Entrez la biographie de l\'intervenant';

  @override
  String get imageUrlHint => 'Entrez l\'URL de l\'image de l\'intervenant';

  @override
  String get twitterHint => 'Entrez l\'URL de Twitter';

  @override
  String get githubHint => 'Entrez l\'URL de GitHub';

  @override
  String get linkedinHint => 'Entrez l\'URL de LinkedIn';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get errorUnknown => 'Erreur inconnue';

  @override
  String get createSession => 'Créer une session';

  @override
  String get editSession => 'Modifier la session';

  @override
  String get loadingTitle => 'Chargement...';

  @override
  String get unexpectedError => 'Une erreur inattendue est survenue.';

  @override
  String get titleLabel => 'Titre*';

  @override
  String get talkTitleHint => 'Entrez le titre de la conférence';

  @override
  String get talkTitleError => 'Veuillez entrer un titre pour la conférence';

  @override
  String get eventDayLabel => 'Jour de l\'événement*';

  @override
  String get selectDayHint => 'Sélectionnez un jour';

  @override
  String get selectDayError => 'Veuillez sélectionner un jour';

  @override
  String get roomLabel => 'Salle*';

  @override
  String get selectRoomHint => 'Sélectionnez une salle';

  @override
  String get selectRoomError => 'Veuillez sélectionner une salle';

  @override
  String get startTimeLabel => 'Heure de début :';

  @override
  String get endTimeLabel => 'Heure de fin :';

  @override
  String get timeValidationError =>
      'L\'heure de début doit être antérieure à l\'heure de fin.';

  @override
  String get speakerLabel => 'Intervenant*';

  @override
  String get noSpeakersMessage => 'Aucun intervenant. Ajoutez-en un.';

  @override
  String get selectSpeakerHint => 'Sélectionnez un intervenant';

  @override
  String get selectSpeakerError => 'Veuillez sélectionner un intervenant';

  @override
  String get talkTypeLabel => 'Type de conférence*';

  @override
  String get selectTalkTypeHint => 'Sélectionnez le type de conférence';

  @override
  String get selectTalkTypeError =>
      'Veuillez sélectionner le type de conférence';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get talkDescriptionHint => 'Entrez la description de la conférence...';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get timeSelectionError =>
      'Veuillez sélectionner les heures de début et de fin.';

  @override
  String get noSessionsFound => 'Aucune session trouvée';

  @override
  String get deleteSessionTitle => 'Supprimer la session';

  @override
  String get deleteSessionMessage =>
      'Êtes-vous sûr de vouloir supprimer la session ?';

  @override
  String get editEventTitle => 'Modifier l\'événement';

  @override
  String get createEventTitle => 'Créer l\'événement';

  @override
  String get editingEvent => 'Édition de l\'événement';

  @override
  String get creatingEvent => 'Création de l\'événement';

  @override
  String get eventNameLabel => 'Nom de l\'événement';

  @override
  String get eventNameHint => 'Entrez le nom de l\'événement';

  @override
  String get requiredField => 'Champ obligatoire';

  @override
  String get startDateLabel => 'Date de début';

  @override
  String get dateHint => 'AAAA-MM-JJ';

  @override
  String get endDateLabel => 'Date de fin';

  @override
  String get addEndDate => 'Ajouter une date de fin';

  @override
  String get roomsLabel => 'Salles';

  @override
  String get timezoneLabel => 'Fuseau horaire';

  @override
  String get timezoneHint => 'Entrez le fuseau horaire';

  @override
  String get baseUrlLabel => 'URL de base';

  @override
  String get baseUrlHint => 'Entrez l\'URL de base';

  @override
  String get primaryColorLabel => 'Couleur principale';

  @override
  String get primaryColorHint =>
      'Entrez la couleur principale (par ex. #FFFFFF)';

  @override
  String get secondaryColorLabel => 'Couleur secondaire';

  @override
  String get secondaryColorHint =>
      'Entrez la couleur secondaire (par ex. #000000)';

  @override
  String get venueTitle => 'Lieu';

  @override
  String get venueNameLabel => 'Nom du lieu';

  @override
  String get venueNameHint => 'Entrez le nom du lieu';

  @override
  String get venueAddressLabel => 'Adresse du lieu';

  @override
  String get venueAddressHint => 'Entrez l\'adresse du lieu';

  @override
  String get venueCityLabel => 'Ville du lieu';

  @override
  String get venueCityHint => 'Entrez la ville du lieu';

  @override
  String get eventDescriptionHint => 'Entrez la description de l\'événement';

  @override
  String get errorPrefix => 'Erreur : ';

  @override
  String get errorLoadingConfig =>
      'Erreur lors du chargement de la configuration : ';

  @override
  String get configNotAvailable => 'Erreur : Configuration non disponible';

  @override
  String get noEventsToShow => 'Aucun événement à afficher.';

  @override
  String get eventDeleted => ' supprimé';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get projectNameLabel => 'Nom du projet';

  @override
  String get projectNameHint => 'Veuillez entrer le nom du projet';

  @override
  String get tokenHintLabel => 'Entrez votre jeton GitHub...';

  @override
  String get tokenHint => 'Veuillez entrer un jeton GitHub valide';

  @override
  String get unknownAuthError => 'Échec d\'authentification inconnu.';

  @override
  String projectNotFoundError(Object projectName) {
    return 'Le projet \"$projectName\" n\'existe pas dans vos dépôts GitHub.';
  }

  @override
  String get authNetworkError =>
      'Erreur d\'authentification ou de réseau. Vérifiez vos informations d\'identification et le nom du projet.';

  @override
  String get closeButton => 'Fermer';

  @override
  String get editSponsorTitle => 'Modifier le sponsor';

  @override
  String get createSponsorTitle => 'Créer un sponsor';

  @override
  String get editingSponsor => 'Édition du sponsor';

  @override
  String get creatingSponsor => 'Création du sponsor';

  @override
  String get sponsorNameHint => 'Entrez le nom du sponsor';

  @override
  String get sponsorNameValidation => 'Veuillez entrer le nom du sponsor';

  @override
  String get logoLabel => 'Logo*';

  @override
  String get logoHint => 'Entrez l\'URL du logo';

  @override
  String get logoValidation => 'Logo';

  @override
  String get websiteLabel => 'Web*';

  @override
  String get websiteHint => 'Entrez l\'URL du site web';

  @override
  String get websiteValidation => 'Web';

  @override
  String get mainSponsor => 'Sponsor Principal';

  @override
  String get goldSponsor => 'Sponsor Or';

  @override
  String get silverSponsor => 'Sponsor Argent';

  @override
  String get bronzeSponsor => 'Sponsor Bronze';

  @override
  String get updateButton => 'Mettre à jour';

  @override
  String get addButton => 'Ajouter';

  @override
  String get addRoomTitle => 'Ajouter une salle';

  @override
  String get roomNameHint => 'Nom de la salle';

  @override
  String get formError => 'Il y a des erreurs dans le formulaire';

  @override
  String get confirmLogout => 'Confirmer la déconnexion';

  @override
  String get confirmLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get logout => 'Déconnexion';

  @override
  String get enterGithubTokenTitle => 'Jeton d\'accès';

  @override
  String get availablesEventsTitle => 'Événements Disponibles';

  @override
  String get availablesEventsText =>
      'Explorez les événements à venir et \n trouvez quelque chose qui vous intéresse';

  @override
  String get config => 'Organisation';

  @override
  String get configName => 'Nom de l\'organisation';

  @override
  String get configNameHint => 'Entrez le nom de l\'organisation';

  @override
  String get githubUser => 'Utilisateur GitHub';

  @override
  String get githubUserHint => 'Entrez l\'utilisateur GitHub';

  @override
  String get branch => 'Branche';

  @override
  String get branchHint => 'Entrez la branche';

  @override
  String get eventManager => 'Gestionnaire d\'événements';

  @override
  String get addSession => 'Ajouter une Session';

  @override
  String get addSpeaker => 'Ajouter un Intervenant';

  @override
  String get addSponsor => 'Ajouter un Sponsor';

  @override
  String get retryLater => 'Try again later';

  @override
  String get commonError =>
      'Erreur lors de la récupération des données, veuillez réessayer plus tard';

  @override
  String get addEvent => 'Ajouter un événement';

  @override
  String get createSpeaker => 'Créer un Intervenant';

  @override
  String get deleteSpeaker => 'Supprimer l\'intervenant';

  @override
  String confirmDeleteSpeaker(String speakerName) {
    return 'Êtes-vous sûr de vouloir supprimer l\'intervenant $speakerName?';
  }

  @override
  String get accept => 'Accepter';

  @override
  String get deleteSponsorTitle => 'Supprimer le sponsor';

  @override
  String confirmDeleteSponsor(String sponsorName) {
    return 'Êtes-vous sûr de vouloir supprimer le sponsor $sponsorName ?';
  }

  @override
  String get wrongBranch =>
      'La branche saisie n\'existe pas dans le dépôt. Vérifiez le nom de la branche et réessayez.';

  @override
  String get onLive => 'On Live';

  @override
  String get selectSpeaker => 'Sélectionnez un intervenant';

  @override
  String get onlineNow => 'En ligne maintenant';
}
