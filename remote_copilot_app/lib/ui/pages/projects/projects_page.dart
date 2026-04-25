import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_scaffold.dart';
import 'package:remote_copilot_app/ui/pages/projects/projects_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/projects/projects_page_state.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({required this.repository, this.onOpenDrawer, super.key});

  final RemoteCopilotRepository repository;
  final VoidCallback? onOpenDrawer;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectsPageController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = ProjectsPageController(repository: widget.repository);
    _searchController = TextEditingController();
    _controller.loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final state = _controller.state;

        return HomeNavigationScaffold(
          onOpenDrawer: widget.onOpenDrawer,
          appBarTitle: Text(l10n.commandProjectsLabel),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchBar(
                    controller: _searchController,
                    hintText: l10n.searchProjectsHint,
                    leading: const Icon(Icons.search_rounded),
                    onChanged: _controller.updateSearchQuery,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _ProjectsBody(state: state, controller: _controller),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProjectsBody extends StatelessWidget {
  const _ProjectsBody({required this.state, required this.controller});

  final ProjectsPageController controller;
  final ProjectsPageState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 42, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(l10n.backendUnavailable, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: controller.loadProjects, child: Text(l10n.retryButton)),
          ],
        ),
      );
    }

    if (state.filteredItems.isEmpty) {
      final isFiltering = state.searchQuery.trim().isNotEmpty;
      return _ProjectsEmptyState(
        title: isFiltering ? l10n.noFilteredProjectsTitle : l10n.emptyProjectsTitle,
        description: isFiltering ? l10n.noFilteredProjectsDescription : l10n.emptyProjectsDescription,
      );
    }

    return ListView.separated(
      itemCount: state.filteredItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ProjectTile(item: state.filteredItems[index]);
      },
    );
  }
}

class _ProjectsEmptyState extends StatelessWidget {
  const _ProjectsEmptyState({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_rounded, size: 42, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.item});

  final WorkspaceDefinition item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
      leading: const Icon(Icons.folder_copy_outlined),
      title: Text(item.name),
      subtitle: Text(item.mountedPath, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () {},
    );
  }
}
