import 'package:remote_copilot_app/domain/model/health_snapshot.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';

enum AppStartupStatus { loading, ready, failure }

class AppStartupPageState {
  const AppStartupPageState({
    required this.status,
    required this.baseUrl,
    required this.workspaces,
    this.selectedWorkspaceId,
    this.health,
    this.errorMessage,
    this.isLaunchingSession = false,
  });

  const AppStartupPageState.initial()
      : status = AppStartupStatus.loading,
        baseUrl = '',
        workspaces = const [],
        selectedWorkspaceId = null,
        health = null,
        errorMessage = null,
        isLaunchingSession = false;

  final AppStartupStatus status;
  final String baseUrl;
  final List<WorkspaceDefinition> workspaces;
  final String? selectedWorkspaceId;
  final HealthSnapshot? health;
  final String? errorMessage;
  final bool isLaunchingSession;

  AppStartupPageState copyWith({
    AppStartupStatus? status,
    String? baseUrl,
    List<WorkspaceDefinition>? workspaces,
    String? selectedWorkspaceId,
    HealthSnapshot? health,
    String? errorMessage,
    bool? isLaunchingSession,
  }) {
    return AppStartupPageState(
      status: status ?? this.status,
      baseUrl: baseUrl ?? this.baseUrl,
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspaceId: selectedWorkspaceId ?? this.selectedWorkspaceId,
      health: health ?? this.health,
      errorMessage: errorMessage,
      isLaunchingSession: isLaunchingSession ?? this.isLaunchingSession,
    );
  }
}
