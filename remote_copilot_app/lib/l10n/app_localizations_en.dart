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
  String get projectsHeroTitle => 'Work across your projects';

  @override
  String get projectsHeroDescription =>
      'Manage project folders, sync the catalog, and open remote Copilot sessions on any mounted repository.';

  @override
  String projectsCountLabel(Object count) {
    return '$count active projects';
  }

  @override
  String selectedProjectLabel(Object projectName) {
    return 'Active project: $projectName';
  }

  @override
  String get selectedProjectFallbackLabel => 'Pick a project to focus the work';

  @override
  String get generalModeLabel => 'Or stay in general mode for quick ideation';

  @override
  String get projectCatalogTitle => 'Project catalog';

  @override
  String get projectCatalogDescription =>
      'Each child folder under the mounted root lives here as an independent project with its own Copilot session.';

  @override
  String get projectCatalogVisualDescription =>
      'Managing persistent remote environments';

  @override
  String get commandProjectsLabel => 'Projects';

  @override
  String get commandDeployLabel => 'Deploy';

  @override
  String get cpuLoadLabel => 'CPU Load';

  @override
  String get ramUsageLabel => 'RAM Usage';

  @override
  String get activeNodesLabel => 'Active Nodes';

  @override
  String get latencyLabel => 'Latency';

  @override
  String get createProjectTitle => 'Create project';

  @override
  String get createProjectAction => 'Create project';

  @override
  String get renameProjectTitle => 'Edit project';

  @override
  String get renameProjectAction => 'Save changes';

  @override
  String get deleteProjectAction => 'Delete project';

  @override
  String get syncProjectsAction => 'Sync projects';

  @override
  String get projectNameLabel => 'Project name';

  @override
  String get projectNameHint => 'my-project';

  @override
  String get projectPathLabel => 'Mounted folder';

  @override
  String get emptyProjectsTitle => 'No projects yet';

  @override
  String get emptyProjectsDescription =>
      'Create a new folder inside the mounted root or sync to load the ones that already exist.';

  @override
  String get noFilteredProjectsTitle => 'No matching projects';

  @override
  String get noFilteredProjectsDescription =>
      'Adjust the search or change the filter to show projects again.';

  @override
  String get searchProjectsHint => 'Search by name or path';

  @override
  String get filterAllProjectsLabel => 'All';

  @override
  String get filterActiveProjectsLabel => 'Active';

  @override
  String get filterAttentionProjectsLabel => 'Needs review';

  @override
  String projectLastUsedLabel(Object date) {
    return 'Last used: $date';
  }

  @override
  String projectNeverUsedLabel(Object date) {
    return 'Created: $date';
  }

  @override
  String get projectStatusActive => 'Active';

  @override
  String get projectStatusIdle => 'Idle';

  @override
  String get projectStatusAttention => 'Needs review';

  @override
  String deleteProjectTitle(Object projectName) {
    return 'Delete $projectName';
  }

  @override
  String deleteProjectMessage(Object projectPath) {
    return 'The project folder at $projectPath will be removed and it will disappear from the app.';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get generalConversationTitle => 'General conversation';

  @override
  String get generalConversationDescription =>
      'Start a remote Copilot chat without attaching it to any project. This is useful for exploring ideas before jumping into a repository.';

  @override
  String get generalConversationFeatureTitle => 'Best for shaping ideas';

  @override
  String get generalConversationFeatureDescription =>
      'Use it to discuss strategy, design changes, or prepare prompts before entering a specific project.';

  @override
  String get openGeneralConversationButton => 'Open general conversation';

  @override
  String get workspaceSectionTitle => 'Project';

  @override
  String get workspaceConversationDescription =>
      'Attach the conversation to a mounted project so Copilot can operate inside that repository.';

  @override
  String get openWorkspaceConversationButton => 'Open project conversation';

  @override
  String get openProjectConversationButton => 'Open project chat';

  @override
  String get newConversationLabel => 'New conversation';

  @override
  String get chatsLabel => 'Chats';

  @override
  String get chatsPageTitle => 'Chats';

  @override
  String get chatsSearchHint => 'Search chats';

  @override
  String get chatsEmptyTitle => 'No chat history yet';

  @override
  String get chatsEmptyDescription =>
      'Your past conversations will appear here when the backend exposes chat history.';

  @override
  String get deleteChatHistoryAction => 'Delete chat';

  @override
  String deleteChatHistoryTitle(Object chatTitle) {
    return 'Delete $chatTitle';
  }

  @override
  String get deleteChatHistoryMessage =>
      'This chat will disappear from the history and its persisted messages will be removed.';

  @override
  String get streamingTelemetryLabel => 'Streaming telemetry';

  @override
  String get projectsRootHint =>
      'The app manages projects as child folders inside the backend mounted root.';

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
  String get emptyConversationPrompt => 'How can I help you?';

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
