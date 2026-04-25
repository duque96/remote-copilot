import 'package:flutter/foundation.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/ui/pages/chats/chats_page_state.dart';

class ChatsPageController extends ChangeNotifier {
  ChatsPageController({required RemoteCopilotRepository repository}) : _repository = repository, _state = const ChatsPageState.initial();

  final RemoteCopilotRepository _repository;

  ChatsPageState _state;

  ChatsPageState get state => _state;

  Future<void> initialize() async {
    _state = _state.copyWith(status: ChatsPageStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final sessions = await _repository.listSessions();
      _state = _state.copyWith(
        status: ChatsPageStatus.ready,
        items: sessions.map(ChatHistoryItem.fromSession).toList(growable: false),
        errorMessage: null,
      );
    } catch (error) {
      _state = _state.copyWith(status: ChatsPageStatus.failure, errorMessage: error.toString());
    }

    notifyListeners();
  }

  void updateSearchQuery(String value) {
    if (value == _state.searchQuery) {
      return;
    }

    _state = _state.copyWith(searchQuery: value);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);

    _state = _state.copyWith(items: _state.items.where((item) => item.id != sessionId).toList(growable: false), errorMessage: null);
    notifyListeners();
  }
}
