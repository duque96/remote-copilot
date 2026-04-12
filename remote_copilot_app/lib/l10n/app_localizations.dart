import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote Copilot'**
  String get appTitle;

  /// No description provided for @backendUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the backend.'**
  String get backendUnavailable;

  /// No description provided for @backendSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get backendSectionTitle;

  /// No description provided for @baseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL: {baseUrl}'**
  String baseUrlLabel(Object baseUrl);

  /// No description provided for @healthSummary.
  ///
  /// In en, this message translates to:
  /// **'API {apiVersion} • {apiStatus} • DB {databaseStatus} • Copilot {copilotStatus}'**
  String healthSummary(
    Object apiVersion,
    Object apiStatus,
    Object databaseStatus,
    Object copilotStatus,
  );

  /// No description provided for @healthStatusOk.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get healthStatusOk;

  /// No description provided for @healthStatusDown.
  ///
  /// In en, this message translates to:
  /// **'down'**
  String get healthStatusDown;

  /// No description provided for @generalConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'General conversation'**
  String get generalConversationTitle;

  /// No description provided for @generalConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a remote Copilot chat without attaching it to any mounted workspace.'**
  String get generalConversationDescription;

  /// No description provided for @openGeneralConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Open general conversation'**
  String get openGeneralConversationButton;

  /// No description provided for @workspaceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspaceSectionTitle;

  /// No description provided for @workspaceConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Attach the conversation to a mounted workspace so Copilot can operate inside that repository.'**
  String get workspaceConversationDescription;

  /// No description provided for @openWorkspaceConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Open workspace conversation'**
  String get openWorkspaceConversationButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @backendUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get backendUrlLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @messageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get messageInputHint;

  /// No description provided for @attachmentsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Attachments coming soon'**
  String get attachmentsComingSoon;

  /// No description provided for @sendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTooltip;

  /// No description provided for @thinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinkingLabel;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @assistantLabel.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get assistantLabel;

  /// No description provided for @assistantReasoningLabel.
  ///
  /// In en, this message translates to:
  /// **'Reasoning'**
  String get assistantReasoningLabel;

  /// No description provided for @assistantContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get assistantContextLabel;

  /// No description provided for @assistantToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get assistantToolsLabel;

  /// No description provided for @assistantSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get assistantSkillsLabel;

  /// No description provided for @assistantControlsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get assistantControlsLabel;

  /// No description provided for @assistantFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String assistantFilesCount(Object count);

  /// No description provided for @assistantToolsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tools'**
  String assistantToolsCount(Object count);

  /// No description provided for @assistantSkillsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} skills'**
  String assistantSkillsCount(Object count);

  /// No description provided for @assistantInteractionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} interactions'**
  String assistantInteractionsCount(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
