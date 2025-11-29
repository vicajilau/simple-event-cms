import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('fr'),
    Locale('gl'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @loadingAgenda.
  ///
  /// In en, this message translates to:
  /// **'Loading agenda...'**
  String get loadingAgenda;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noEventsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled'**
  String get noEventsScheduled;

  /// No description provided for @loadingSpeakers.
  ///
  /// In en, this message translates to:
  /// **'Loading speakers...'**
  String get loadingSpeakers;

  /// No description provided for @noSpeakersRegistered.
  ///
  /// In en, this message translates to:
  /// **'No speakers registered'**
  String get noSpeakersRegistered;

  /// No description provided for @loadingSponsors.
  ///
  /// In en, this message translates to:
  /// **'Loading sponsors...'**
  String get loadingSponsors;

  /// No description provided for @noSponsorsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No sponsors registered'**
  String get noSponsorsRegistered;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get errorLoadingImage;

  /// No description provided for @keynote.
  ///
  /// In en, this message translates to:
  /// **'KEYNOTE'**
  String get keynote;

  /// No description provided for @talk.
  ///
  /// In en, this message translates to:
  /// **'TALK'**
  String get talk;

  /// No description provided for @workshop.
  ///
  /// In en, this message translates to:
  /// **'WORKSHOP'**
  String get workshop;

  /// No description provided for @sessionBreak.
  ///
  /// In en, this message translates to:
  /// **'BREAK'**
  String get sessionBreak;

  /// No description provided for @agenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @speakers.
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get speakers;

  /// No description provided for @sponsors.
  ///
  /// In en, this message translates to:
  /// **'Sponsors'**
  String get sponsors;

  /// No description provided for @nextEvent.
  ///
  /// In en, this message translates to:
  /// **'Next event...'**
  String get nextEvent;

  /// No description provided for @eventInfo.
  ///
  /// In en, this message translates to:
  /// **'Event Information'**
  String get eventInfo;

  /// No description provided for @eventDates.
  ///
  /// In en, this message translates to:
  /// **'Event Dates'**
  String get eventDates;

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @visibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilityLabel;

  /// No description provided for @eventIsOpenByDefault.
  ///
  /// In en, this message translates to:
  /// **'Event is open by default'**
  String get eventIsOpenByDefault;

  /// No description provided for @eventIsNotOpenByDefault.
  ///
  /// In en, this message translates to:
  /// **'Event is not open by default'**
  String get eventIsNotOpenByDefault;

  /// No description provided for @openByDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Open by default'**
  String get openByDefaultLabel;

  /// No description provided for @eventIsVisible.
  ///
  /// In en, this message translates to:
  /// **'Event is visible'**
  String get eventIsVisible;

  /// No description provided for @changeVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Visibility'**
  String get changeVisibilityTitle;

  /// No description provided for @changeVisibilityToHidden.
  ///
  /// In en, this message translates to:
  /// **'This will make the event not appear to users'**
  String get changeVisibilityToHidden;

  /// No description provided for @changeVisibilityToVisible.
  ///
  /// In en, this message translates to:
  /// **'From now on the event will be visible to everyone'**
  String get changeVisibilityToVisible;

  /// No description provided for @eventIsHidden.
  ///
  /// In en, this message translates to:
  /// **'Event is hidden'**
  String get eventIsHidden;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter/X'**
  String get twitter;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @openUrl.
  ///
  /// In en, this message translates to:
  /// **'Open URL'**
  String get openUrl;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @deleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEventTitle;

  /// No description provided for @deleteEventMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event? \n This will delete the sessions associated with the event.'**
  String get deleteEventMessage;

  /// No description provided for @speakerForm.
  ///
  /// In en, this message translates to:
  /// **'Speaker Form'**
  String get speakerForm;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name*'**
  String get nameLabel;

  /// No description provided for @nameErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameErrorHint;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Biography*'**
  String get bioLabel;

  /// No description provided for @bioErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your biography'**
  String get bioErrorHint;

  /// No description provided for @imageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrlLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the speaker\'s name'**
  String get nameHint;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the speaker\'s biography'**
  String get bioHint;

  /// No description provided for @imageUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the speaker\'s image URL'**
  String get imageUrlHint;

  /// No description provided for @twitterHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Twitter URL'**
  String get twitterHint;

  /// No description provided for @githubHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the GitHub URL'**
  String get githubHint;

  /// No description provided for @linkedinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the LinkedIn URL'**
  String get linkedinHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnknown;

  /// No description provided for @createSession.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get createSession;

  /// No description provided for @editSession.
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get editSession;

  /// No description provided for @loadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingTitle;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error has occurred.'**
  String get unexpectedError;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title*'**
  String get titleLabel;

  /// No description provided for @talkTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter talk title'**
  String get talkTitleHint;

  /// No description provided for @talkTitleError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a talk title'**
  String get talkTitleError;

  /// No description provided for @eventDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Event day*'**
  String get eventDayLabel;

  /// No description provided for @selectDayHint.
  ///
  /// In en, this message translates to:
  /// **'Select a day'**
  String get selectDayHint;

  /// No description provided for @selectDayError.
  ///
  /// In en, this message translates to:
  /// **'Please select a day'**
  String get selectDayError;

  /// No description provided for @roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room*'**
  String get roomLabel;

  /// No description provided for @selectRoomHint.
  ///
  /// In en, this message translates to:
  /// **'Select a room'**
  String get selectRoomHint;

  /// No description provided for @selectRoomError.
  ///
  /// In en, this message translates to:
  /// **'Please select a room'**
  String get selectRoomError;

  /// No description provided for @startTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start time:'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End time:'**
  String get endTimeLabel;

  /// No description provided for @timeValidationError.
  ///
  /// In en, this message translates to:
  /// **'Start time must be before end time.'**
  String get timeValidationError;

  /// No description provided for @speakerLabel.
  ///
  /// In en, this message translates to:
  /// **'Speaker*'**
  String get speakerLabel;

  /// No description provided for @noSpeakersMessage.
  ///
  /// In en, this message translates to:
  /// **'No speakers. Add one.'**
  String get noSpeakersMessage;

  /// No description provided for @selectSpeakerHint.
  ///
  /// In en, this message translates to:
  /// **'Select a speaker'**
  String get selectSpeakerHint;

  /// No description provided for @selectSpeakerError.
  ///
  /// In en, this message translates to:
  /// **'Please select a speaker'**
  String get selectSpeakerError;

  /// No description provided for @talkTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Talk type*'**
  String get talkTypeLabel;

  /// No description provided for @selectTalkTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select the talk type'**
  String get selectTalkTypeHint;

  /// No description provided for @selectTalkTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select the talk type'**
  String get selectTalkTypeError;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @talkDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter talk description...'**
  String get talkDescriptionHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @timeSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Please select both start and end times.'**
  String get timeSelectionError;

  /// No description provided for @noSessionsFound.
  ///
  /// In en, this message translates to:
  /// **'No sessions found'**
  String get noSessionsFound;

  /// No description provided for @deleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the session?'**
  String get deleteSessionMessage;

  /// No description provided for @editEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editEventTitle;

  /// No description provided for @createEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get createEventTitle;

  /// No description provided for @editingEvent.
  ///
  /// In en, this message translates to:
  /// **'Editing event'**
  String get editingEvent;

  /// No description provided for @creatingEvent.
  ///
  /// In en, this message translates to:
  /// **'Creating event'**
  String get creatingEvent;

  /// No description provided for @eventNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get eventNameLabel;

  /// No description provided for @eventNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the event name'**
  String get eventNameHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDateLabel;

  /// No description provided for @dateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateHint;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDateLabel;

  /// No description provided for @addEndDate.
  ///
  /// In en, this message translates to:
  /// **'Add end date'**
  String get addEndDate;

  /// No description provided for @roomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsLabel;

  /// No description provided for @timezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneLabel;

  /// No description provided for @timezoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the timezone'**
  String get timezoneHint;

  /// No description provided for @baseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrlLabel;

  /// No description provided for @baseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Base URL'**
  String get baseUrlHint;

  /// No description provided for @primaryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColorLabel;

  /// No description provided for @primaryColorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the primary color (e.g. #FFFFFF)'**
  String get primaryColorHint;

  /// No description provided for @secondaryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get secondaryColorLabel;

  /// No description provided for @secondaryColorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the secondary color (e.g. #000000)'**
  String get secondaryColorHint;

  /// No description provided for @venueTitle.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venueTitle;

  /// No description provided for @venueNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue Name'**
  String get venueNameLabel;

  /// No description provided for @venueNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue name'**
  String get venueNameHint;

  /// No description provided for @venueAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue Address'**
  String get venueAddressLabel;

  /// No description provided for @venueAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue address'**
  String get venueAddressHint;

  /// No description provided for @venueCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Venue City'**
  String get venueCityLabel;

  /// No description provided for @venueCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the venue city'**
  String get venueCityHint;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the event description'**
  String get eventDescriptionHint;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @errorLoadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Error loading configuration: '**
  String get errorLoadingConfig;

  /// No description provided for @configNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Error: Configuration not available'**
  String get configNotAvailable;

  /// No description provided for @noEventsToShow.
  ///
  /// In en, this message translates to:
  /// **'No events to show.'**
  String get noEventsToShow;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **' deleted'**
  String get eventDeleted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the project name'**
  String get projectNameHint;

  /// No description provided for @tokenHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Introduce tu client secret para continuar'**
  String get tokenHintLabel;

  /// No description provided for @tokenHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid GitHub token'**
  String get tokenHint;

  /// No description provided for @unknownAuthError.
  ///
  /// In en, this message translates to:
  /// **'Unknown authentication failure.'**
  String get unknownAuthError;

  /// No description provided for @projectNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The project \"{projectName}\" does not exist in your GitHub repositories.'**
  String projectNotFoundError(Object projectName);

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Authentication or network error. Check your credentials and project name.'**
  String get authNetworkError;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @editSponsorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sponsor'**
  String get editSponsorTitle;

  /// No description provided for @createSponsorTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Sponsor'**
  String get createSponsorTitle;

  /// No description provided for @editingSponsor.
  ///
  /// In en, this message translates to:
  /// **'Editing Sponsor'**
  String get editingSponsor;

  /// No description provided for @creatingSponsor.
  ///
  /// In en, this message translates to:
  /// **'Creating Sponsor'**
  String get creatingSponsor;

  /// No description provided for @sponsorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the Sponsor\'s name'**
  String get sponsorNameHint;

  /// No description provided for @sponsorNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter the Sponsor\'s name'**
  String get sponsorNameValidation;

  /// No description provided for @logoLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo*'**
  String get logoLabel;

  /// No description provided for @logoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the logo URL'**
  String get logoHint;

  /// No description provided for @logoValidation.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logoValidation;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Web*'**
  String get websiteLabel;

  /// No description provided for @websiteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the website URL'**
  String get websiteHint;

  /// No description provided for @websiteValidation.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get websiteValidation;

  /// No description provided for @mainSponsor.
  ///
  /// In en, this message translates to:
  /// **'Main Sponsor'**
  String get mainSponsor;

  /// No description provided for @goldSponsor.
  ///
  /// In en, this message translates to:
  /// **'Gold Sponsor'**
  String get goldSponsor;

  /// No description provided for @silverSponsor.
  ///
  /// In en, this message translates to:
  /// **'Silver Sponsor'**
  String get silverSponsor;

  /// No description provided for @bronzeSponsor.
  ///
  /// In en, this message translates to:
  /// **'Bronze Sponsor'**
  String get bronzeSponsor;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add Button'**
  String get addButton;

  /// No description provided for @addRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoomTitle;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get roomNameHint;

  /// No description provided for @formError.
  ///
  /// In en, this message translates to:
  /// **'There are errors in the form'**
  String get formError;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @enterGithubTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Token'**
  String get enterGithubTokenTitle;

  /// No description provided for @availablesEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Events'**
  String get availablesEventsTitle;

  /// No description provided for @availablesEventsText.
  ///
  /// In en, this message translates to:
  /// **'Explore upcoming events and\nfind something that interests you'**
  String get availablesEventsText;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get config;

  /// No description provided for @configName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get configName;

  /// No description provided for @configNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the config name'**
  String get configNameHint;

  /// No description provided for @githubUser.
  ///
  /// In en, this message translates to:
  /// **'GitHub User'**
  String get githubUser;

  /// No description provided for @githubUserHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the GitHub user'**
  String get githubUserHint;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @branchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the branch'**
  String get branchHint;

  /// No description provided for @eventManager.
  ///
  /// In en, this message translates to:
  /// **'Event manager'**
  String get eventManager;

  /// No description provided for @addSession.
  ///
  /// In en, this message translates to:
  /// **'Add Session'**
  String get addSession;

  /// No description provided for @addSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Add Speaker'**
  String get addSpeaker;

  /// No description provided for @addSponsor.
  ///
  /// In en, this message translates to:
  /// **'Add Sponsor'**
  String get addSponsor;

  /// No description provided for @retryLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get retryLater;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching data, Please retry later'**
  String get commonError;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @createSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Create Speaker'**
  String get createSpeaker;

  /// No description provided for @deleteSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Delete speaker'**
  String get deleteSpeaker;

  /// Confirm speaker deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the speaker {speakerName}?'**
  String confirmDeleteSpeaker(String speakerName);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @deleteSponsorTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sponsor'**
  String get deleteSponsorTitle;

  /// Confirm sponsor deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the sponsor {sponsorName}?'**
  String confirmDeleteSponsor(String sponsorName);

  /// No description provided for @wrongBranch.
  ///
  /// In en, this message translates to:
  /// **'The entered branch does not exist in the repository. Check the branch name and try again.'**
  String get wrongBranch;

  /// No description provided for @onLive.
  ///
  /// In en, this message translates to:
  /// **'On Live'**
  String get onLive;

  /// No description provided for @selectSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Select a speaker'**
  String get selectSpeaker;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online Now'**
  String get onlineNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'en',
    'es',
    'eu',
    'fr',
    'gl',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
    case 'fr':
      return AppLocalizationsFr();
    case 'gl':
      return AppLocalizationsGl();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
