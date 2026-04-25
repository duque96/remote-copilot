import 'package:remote_copilot_app/domain/model/workspace_definition.dart';

class ProjectsPageState {
  const ProjectsPageState({required this.searchQuery, this.items = const [], this.isLoading = false, this.hasError = false});

  final String searchQuery;
  final List<WorkspaceDefinition> items;
  final bool isLoading;
  final bool hasError;

  List<WorkspaceDefinition> get filteredItems {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items
        .where((item) {
          return item.name.toLowerCase().contains(normalizedQuery) || item.mountedPath.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  ProjectsPageState copyWith({String? searchQuery, List<WorkspaceDefinition>? items, bool? isLoading, bool? hasError}) {
    return ProjectsPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}
