import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_scaffold.dart';
import 'package:remote_copilot_app/ui/pages/chats/chats_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/chats/chats_page_state.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({required this.repository, required this.onSessionSelected, this.onOpenDrawer, super.key});

  final RemoteCopilotRepository repository;
  final Future<void> Function(String sessionId) onSessionSelected;

  final VoidCallback? onOpenDrawer;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final ChatsPageController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _controller = ChatsPageController(repository: widget.repository)..initialize();
    _searchController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ChatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _controller.initialize();
    }
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
          appBarTitle: Text(l10n.chatsPageTitle),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchBar(
                    controller: _searchController,
                    hintText: l10n.chatsSearchHint,
                    leading: const Icon(Icons.search_rounded),
                    onChanged: _controller.updateSearchQuery,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: switch (state.status) {
                      ChatsPageStatus.loading => const Center(child: CircularProgressIndicator()),
                      ChatsPageStatus.failure => _ChatsEmptyState(
                        title: l10n.backendUnavailable,
                        description: state.errorMessage ?? l10n.chatsEmptyDescription,
                      ),
                      ChatsPageStatus.ready =>
                        state.filteredItems.isEmpty
                            ? _ChatsEmptyState(title: l10n.chatsEmptyTitle, description: l10n.chatsEmptyDescription)
                            : ListView.separated(
                                itemCount: state.filteredItems.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = state.filteredItems[index];
                                  return _ChatHistoryTile(
                                    item: item,
                                    onTap: () => widget.onSessionSelected(item.id),
                                    onDelete: () => _confirmDelete(item),
                                  );
                                },
                              ),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(ChatHistoryItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteChatHistoryTitle(item.title)),
          content: Text(l10n.deleteChatHistoryMessage),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.cancelButton)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.deleteChatHistoryAction)),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await _controller.deleteSession(item.id);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _ChatsEmptyState extends StatelessWidget {
  const _ChatsEmptyState({required this.title, required this.description});

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
            Icon(Icons.history_rounded, size: 42, color: theme.colorScheme.onSurfaceVariant),
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

class _ChatHistoryTile extends StatelessWidget {
  const _ChatHistoryTile({required this.item, required this.onTap, required this.onDelete});

  final ChatHistoryItem item;
  final Future<void> Function() onTap;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
      leading: Icon(item.workspaceId == null ? Icons.chat_bubble_outline_rounded : Icons.folder_open_rounded),
      title: Text(item.title),
      subtitle: item.preview.isEmpty ? null : Text(item.preview, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(onPressed: onDelete, tooltip: l10n.deleteChatHistoryAction, icon: const Icon(Icons.delete_outline_rounded)),
      onTap: onTap,
    );
  }
}
