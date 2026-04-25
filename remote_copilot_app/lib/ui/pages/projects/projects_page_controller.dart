import 'package:flutter/foundation.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/ui/pages/projects/projects_page_state.dart';

class ProjectsPageController extends ChangeNotifier {
  ProjectsPageController({required RemoteCopilotRepository repository})
    : _repository = repository,
      _state = const ProjectsPageState(searchQuery: '', isLoading: true);

  final RemoteCopilotRepository _repository;
  ProjectsPageState _state;

  ProjectsPageState get state => _state;

  Future<void> loadProjects() async {
    _state = _state.copyWith(isLoading: true, hasError: false);
    notifyListeners();

    try {
      final items = await _repository.getWorkspaces();
      _state = _state.copyWith(items: items, isLoading: false, hasError: false);
    } catch (_) {
      _state = _state.copyWith(isLoading: false, hasError: true);
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
}
