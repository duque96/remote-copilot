import 'package:flutter/foundation.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_drawer.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/home_page_state.dart';

class HomePageController extends ChangeNotifier {
  HomePageController({required RemoteCopilotRepository repository, required SettingsService settingsService})
    : _repository = repository,
      _settingsService = settingsService;

  final RemoteCopilotRepository _repository;
  final SettingsService _settingsService;

  HomePageState _state = const HomePageState.initial();

  HomePageState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(status: HomePageStatus.loading, errorMessage: null);
    notifyListeners();

    final baseUrl = await _settingsService.loadBaseUrl();
    _repository.baseUrl = baseUrl;

    try {
      await _repository.getHealth();
      _state = _state.copyWith(status: HomePageStatus.ready, baseUrl: _repository.baseUrl, errorMessage: null);
    } catch (error) {
      _state = _state.copyWith(status: HomePageStatus.failure, baseUrl: _repository.baseUrl, errorMessage: error.toString());
    }

    notifyListeners();
  }

  Future<void> saveBaseUrl(String baseUrl) async {
    await _settingsService.saveBaseUrl(baseUrl.trim());
    await initialize();
  }

  void selectSection(ChatNavigationDrawerItem section) {
    if (_state.selectedSection == section && section != ChatNavigationDrawerItem.chats) {
      return;
    }

    _state = _state.copyWith(
      selectedSection: section,
      chatsRefreshSeed: section == ChatNavigationDrawerItem.chats ? _state.chatsRefreshSeed + 1 : _state.chatsRefreshSeed,
    );
    notifyListeners();
  }

  void startNewConversation() {
    _state = _state.copyWith(
      selectedSection: ChatNavigationDrawerItem.newConversation,
      chatInstanceSeed: _state.chatInstanceSeed + 1,
      activeSessionBundle: null,
    );
    notifyListeners();
  }

  Future<void> openExistingSession(String sessionId) async {
    final bundle = await _repository.getSession(sessionId);
    _openSessionBundle(bundle);
  }

  void _openSessionBundle(RemoteSessionBundle bundle) {
    _state = _state.copyWith(
      selectedSection: ChatNavigationDrawerItem.newConversation,
      chatInstanceSeed: _state.chatInstanceSeed + 1,
      activeSessionBundle: bundle,
      errorMessage: null,
    );
    notifyListeners();
  }
}
