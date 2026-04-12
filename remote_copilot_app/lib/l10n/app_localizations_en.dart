// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Remote Copilot';

  @override
  String get backendUnavailable => 'Unable to reach the backend.';

  @override
  String get backendSectionTitle => 'Backend';

  @override
  String baseUrlLabel(Object baseUrl) {
    return 'Base URL: $baseUrl';
  }

  @override
  String healthSummary(
    Object apiVersion,
    Object apiStatus,
    Object databaseStatus,
    Object copilotStatus,
  ) {
    return 'API $apiVersion • $apiStatus • DB $databaseStatus • Copilot $copilotStatus';
  }

  @override
  String get healthStatusOk => 'ok';

  @override
  String get healthStatusDown => 'down';

  @override
  String get generalConversationTitle => 'General conversation';

  @override
  String get generalConversationDescription =>
      'Start a remote Copilot chat without attaching it to any mounted workspace.';

  @override
  String get openGeneralConversationButton => 'Open general conversation';

  @override
  String get workspaceSectionTitle => 'Workspace';

  @override
  String get workspaceConversationDescription =>
      'Attach the conversation to a mounted workspace so Copilot can operate inside that repository.';

  @override
  String get openWorkspaceConversationButton => 'Open workspace conversation';

  @override
  String get retryButton => 'Retry';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get backendUrlLabel => 'Backend URL';

  @override
  String get saveButton => 'Save';

  @override
  String get messageInputHint => 'Write a message';

  @override
  String get attachmentsComingSoon => 'Attachments coming soon';

  @override
  String get sendTooltip => 'Send';

  @override
  String get thinkingLabel => 'Thinking...';

  @override
  String get youLabel => 'You';

  @override
  String get assistantLabel => 'Copilot';

  @override
  String get assistantReasoningLabel => 'Reasoning';

  @override
  String get assistantContextLabel => 'Context';

  @override
  String get assistantToolsLabel => 'Tools';

  @override
  String get assistantSkillsLabel => 'Skills';

  @override
  String get assistantControlsLabel => 'Interactions';

  @override
  String assistantFilesCount(Object count) {
    return '$count files';
  }

  @override
  String assistantToolsCount(Object count) {
    return '$count tools';
  }

  @override
  String assistantSkillsCount(Object count) {
    return '$count skills';
  }

  @override
  String assistantInteractionsCount(Object count) {
    return '$count interactions';
  }
}
