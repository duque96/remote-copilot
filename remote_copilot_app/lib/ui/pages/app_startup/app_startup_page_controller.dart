import 'package:flutter/foundation.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/ui/pages/app_startup/app_startup_page_state.dart';

class AppStartupPageController extends ChangeNotifier {
  AppStartupPageController({required RemoteCopilotRepository repository, required SettingsService settingsService})
    : _repository = repository,
      _settingsService = settingsService;

  final RemoteCopilotRepository _repository;
  final SettingsService _settingsService;

  AppStartupPageState _state = const AppStartupPageState.initial();

  AppStartupPageState get state => _state;

  Future<void> initialize() async {
    final baseUrl = await _settingsService.loadBaseUrl();
    _repository.baseUrl = baseUrl;

    try {
      final health = await _repository.getHealth();
      final workspaces = await _repository.getWorkspaces();

      _state = AppStartupPageState(
        status: AppStartupStatus.ready,
        baseUrl: _repository.baseUrl,
        workspaces: workspaces,
        selectedWorkspaceId: workspaces.isEmpty ? null : workspaces.first.id,
        health: health,
      );
      notifyListeners();
    } catch (error) {
      _state = AppStartupPageState(
        status: AppStartupStatus.failure,
        baseUrl: _repository.baseUrl,
        workspaces: const [],
        errorMessage: error.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    final normalized = baseUrl.trim();
    await _settingsService.saveBaseUrl(normalized);
    await initialize();
  }

  void selectWorkspace(String? workspaceId) {
    _state = _state.copyWith(selectedWorkspaceId: workspaceId);
    notifyListeners();
  }

  Future<RemoteSessionBundle?> createSession({String? workspaceId}) async {
    _state = _state.copyWith(isLaunchingSession: true, errorMessage: null);
    notifyListeners();

    try {
      final bundle = await _repository.createSession(workspaceId: workspaceId);
      _state = _state.copyWith(isLaunchingSession: false);
      notifyListeners();
      return bundle;
    } catch (error) {
      _state = _state.copyWith(isLaunchingSession: false, errorMessage: error.toString());
      notifyListeners();
      return null;
    }
  }
}
