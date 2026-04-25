import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_drawer.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_scaffold.dart';
import 'package:remote_copilot_app/ui/pages/chats/chats_page.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/home_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/home_page_state.dart';
import 'package:remote_copilot_app/ui/pages/projects/projects_page.dart';
import 'package:remote_copilot_app/ui/pages/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.repository,
    required this.settingsService,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final RemoteCopilotRepository repository;
  final SettingsService settingsService;
  final ThemeMode currentThemeMode;
  final Future<void> Function(ThemeMode themeMode) onThemeModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final HomePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomePageController(repository: widget.repository, settingsService: widget.settingsService)..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _openSettings() async {
    final state = _controller.state;
    final result = await Navigator.of(context).push<SettingsPageResult>(
      MaterialPageRoute(
        builder: (_) => SettingsPage(initialBaseUrl: state.baseUrl, initialThemeMode: widget.currentThemeMode),
      ),
    );

    if (result == null) {
      return;
    }

    if (result.themeMode != widget.currentThemeMode) {
      await widget.onThemeModeChanged(result.themeMode);
    }

    if (result.baseUrl.isNotEmpty && result.baseUrl != state.baseUrl) {
      await _controller.saveBaseUrl(result.baseUrl);
    }
  }

  Widget _buildReadyBody(HomePageState state) {
    return IndexedStack(
      index: state.selectedSection.index,
      children: [
        ChatPage(
          key: ValueKey('chat-${state.chatInstanceSeed}'),
          repository: widget.repository,
          sessionBundle: state.activeSessionBundle,
          onOpenDrawer: _openDrawer,
        ),
        ChatsPage(
          key: ValueKey('chats-${state.chatsRefreshSeed}'),
          repository: widget.repository,
          onSessionSelected: _controller.openExistingSession,
          onOpenDrawer: _openDrawer,
        ),
        ProjectsPage(repository: widget.repository, onOpenDrawer: _openDrawer),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final state = _controller.state;

        return Scaffold(
          key: _scaffoldKey,
          drawer: HomeNavigationDrawer(
            title: l10n.appTitle,
            newConversationLabel: l10n.newConversationLabel,
            chatsLabel: l10n.chatsLabel,
            projectsLabel: l10n.commandProjectsLabel,
            settingsTooltip: l10n.settingsTitle,
            selectedItem: state.selectedSection,
            onStartNewConversation: () async => _controller.startNewConversation(),
            onOpenChats: () async => _controller.selectSection(ChatNavigationDrawerItem.chats),
            onOpenProjects: () async => _controller.selectSection(ChatNavigationDrawerItem.projects),
            onOpenSettings: _openSettings,
          ),
          body: switch (state.status) {
            HomePageStatus.loading => HomeNavigationScaffold(
              onOpenDrawer: _openDrawer,
              appBarTitle: Text(l10n.appTitle),
              body: const Center(child: CircularProgressIndicator()),
            ),
            HomePageStatus.failure => HomeNavigationScaffold(
              onOpenDrawer: _openDrawer,
              appBarTitle: Text(l10n.appTitle),
              body: _HomeShellErrorState(message: state.errorMessage ?? l10n.backendUnavailable, onRetry: _controller.initialize),
            ),
            HomePageStatus.ready => _buildReadyBody(state),
          },
        );
      },
    );
  }
}

class _HomeShellErrorState extends StatelessWidget {
  const _HomeShellErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 32, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.backendUnavailable, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: Text(l10n.retryButton)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
