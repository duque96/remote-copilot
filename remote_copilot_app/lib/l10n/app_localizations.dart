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

  /// No description provided for @projectsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Work across your projects'**
  String get projectsHeroTitle;

  /// No description provided for @projectsHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage project folders, sync the catalog, and open remote Copilot sessions on any mounted repository.'**
  String get projectsHeroDescription;

  /// No description provided for @projectsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} active projects'**
  String projectsCountLabel(Object count);

  /// No description provided for @selectedProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Active project: {projectName}'**
  String selectedProjectLabel(Object projectName);

  /// No description provided for @selectedProjectFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick a project to focus the work'**
  String get selectedProjectFallbackLabel;

  /// No description provided for @generalModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Or stay in general mode for quick ideation'**
  String get generalModeLabel;

  /// No description provided for @projectCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Project catalog'**
  String get projectCatalogTitle;

  /// No description provided for @projectCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Each child folder under the mounted root lives here as an independent project with its own Copilot session.'**
  String get projectCatalogDescription;

  /// No description provided for @projectCatalogVisualDescription.
  ///
  /// In en, this message translates to:
  /// **'Managing persistent remote environments'**
  String get projectCatalogVisualDescription;

  /// No description provided for @commandProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get commandProjectsLabel;

  /// No description provided for @commandDeployLabel.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get commandDeployLabel;

  /// No description provided for @cpuLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'CPU Load'**
  String get cpuLoadLabel;

  /// No description provided for @ramUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'RAM Usage'**
  String get ramUsageLabel;

  /// No description provided for @activeNodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Nodes'**
  String get activeNodesLabel;

  /// No description provided for @latencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get latencyLabel;

  /// No description provided for @createProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProjectTitle;

  /// No description provided for @createProjectAction.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProjectAction;

  /// No description provided for @renameProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get renameProjectTitle;

  /// No description provided for @renameProjectAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get renameProjectAction;

  /// No description provided for @deleteProjectAction.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get deleteProjectAction;

  /// No description provided for @syncProjectsAction.
  ///
  /// In en, this message translates to:
  /// **'Sync projects'**
  String get syncProjectsAction;

  /// No description provided for @projectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'my-project'**
  String get projectNameHint;

  /// No description provided for @projectPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Mounted folder'**
  String get projectPathLabel;

  /// No description provided for @emptyProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get emptyProjectsTitle;

  /// No description provided for @emptyProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new folder inside the mounted root or sync to load the ones that already exist.'**
  String get emptyProjectsDescription;

  /// No description provided for @noFilteredProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching projects'**
  String get noFilteredProjectsTitle;

  /// No description provided for @noFilteredProjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust the search or change the filter to show projects again.'**
  String get noFilteredProjectsDescription;

  /// No description provided for @searchProjectsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or path'**
  String get searchProjectsHint;

  /// No description provided for @filterAllProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllProjectsLabel;

  /// No description provided for @filterActiveProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActiveProjectsLabel;

  /// No description provided for @filterAttentionProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get filterAttentionProjectsLabel;

  /// No description provided for @projectLastUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last used: {date}'**
  String projectLastUsedLabel(Object date);

  /// No description provided for @projectNeverUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String projectNeverUsedLabel(Object date);

  /// No description provided for @projectStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get projectStatusActive;

  /// No description provided for @projectStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get projectStatusIdle;

  /// No description provided for @projectStatusAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get projectStatusAttention;

  /// No description provided for @deleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {projectName}'**
  String deleteProjectTitle(Object projectName);

  /// No description provided for @deleteProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'The project folder at {projectPath} will be removed and it will disappear from the app.'**
  String deleteProjectMessage(Object projectPath);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @generalConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'General conversation'**
  String get generalConversationTitle;

  /// No description provided for @generalConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a remote Copilot chat without attaching it to any project. This is useful for exploring ideas before jumping into a repository.'**
  String get generalConversationDescription;

  /// No description provided for @generalConversationFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Best for shaping ideas'**
  String get generalConversationFeatureTitle;

  /// No description provided for @generalConversationFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Use it to discuss strategy, design changes, or prepare prompts before entering a specific project.'**
  String get generalConversationFeatureDescription;

  /// No description provided for @openGeneralConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Open general conversation'**
  String get openGeneralConversationButton;

  /// No description provided for @workspaceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get workspaceSectionTitle;

  /// No description provided for @workspaceConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Attach the conversation to a mounted project so Copilot can operate inside that repository.'**
  String get workspaceConversationDescription;

  /// No description provided for @openWorkspaceConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Open project conversation'**
  String get openWorkspaceConversationButton;

  /// No description provided for @openProjectConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Open project chat'**
  String get openProjectConversationButton;

  /// No description provided for @newConversationLabel.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversationLabel;

  /// No description provided for @chatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsLabel;

  /// No description provided for @chatsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsPageTitle;

  /// No description provided for @chatsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get chatsSearchHint;

  /// No description provided for @chatsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet'**
  String get chatsEmptyTitle;

  /// No description provided for @chatsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your past conversations will appear here when the backend exposes chat history.'**
  String get chatsEmptyDescription;

  /// No description provided for @deleteChatHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChatHistoryAction;

  /// No description provided for @deleteChatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {chatTitle}'**
  String deleteChatHistoryTitle(Object chatTitle);

  /// No description provided for @deleteChatHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This chat will disappear from the history and its persisted messages will be removed.'**
  String get deleteChatHistoryMessage;

  /// No description provided for @streamingTelemetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Streaming telemetry'**
  String get streamingTelemetryLabel;

  /// No description provided for @projectsRootHint.
  ///
  /// In en, this message translates to:
  /// **'The app manages projects as child folders inside the backend mounted root.'**
  String get projectsRootHint;

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

  /// No description provided for @emptyConversationPrompt.
  ///
  /// In en, this message translates to:
  /// **'How can I help you?'**
  String get emptyConversationPrompt;

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
