import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/pages/app_startup/app_startup_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/app_startup/app_startup_page_state.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page.dart';
import 'package:remote_copilot_app/ui/pages/settings/settings_page.dart';

class AppStartupPage extends StatefulWidget {
  const AppStartupPage({
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
  State<AppStartupPage> createState() => _AppStartupPageState();
}

class _AppStartupPageState extends State<AppStartupPage> {
  late final AppStartupPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppStartupPageController(repository: widget.repository, settingsService: widget.settingsService)..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                onPressed: () async {
                  final settingsResult = await Navigator.of(context).push<SettingsPageResult>(
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(initialBaseUrl: state.baseUrl, initialThemeMode: widget.currentThemeMode),
                    ),
                  );

                  if (settingsResult == null) {
                    return;
                  }

                  if (settingsResult.themeMode != widget.currentThemeMode) {
                    await widget.onThemeModeChanged(settingsResult.themeMode);
                  }

                  if (settingsResult.baseUrl.isNotEmpty && settingsResult.baseUrl != state.baseUrl) {
                    await _controller.saveBaseUrl(settingsResult.baseUrl);
                  }
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: switch (state.status) {
            AppStartupStatus.loading => const Center(child: CircularProgressIndicator()),
            AppStartupStatus.failure => _ErrorState(message: state.errorMessage ?? l10n.backendUnavailable, onRetry: _controller.initialize),
            AppStartupStatus.ready => _ReadyState(
              state: state,
              onWorkspaceChanged: _controller.selectWorkspace,
              onOpenGeneralSession: () async {
                final bundle = await _controller.createSession();
                if (bundle == null || !context.mounted) {
                  return;
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(repository: widget.repository, sessionBundle: bundle),
                  ),
                );
              },
              onOpenWorkspaceSession: () async {
                final selectedWorkspaceId = state.selectedWorkspaceId;
                if (selectedWorkspaceId == null) {
                  return;
                }

                final bundle = await _controller.createSession(workspaceId: selectedWorkspaceId);
                if (bundle == null || !context.mounted) {
                  return;
                }

                final workspace = state.workspaces.firstWhere((item) => item.id == selectedWorkspaceId);

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(repository: widget.repository, workspace: workspace, sessionBundle: bundle),
                  ),
                );
              },
            ),
          },
        );
      },
    );
  }
}

class _ReadyState extends StatelessWidget {
  const _ReadyState({
    required this.state,
    required this.onWorkspaceChanged,
    required this.onOpenGeneralSession,
    required this.onOpenWorkspaceSession,
  });

  final AppStartupPageState state;
  final ValueChanged<String?> onWorkspaceChanged;
  final Future<void> Function() onOpenGeneralSession;
  final Future<void> Function() onOpenWorkspaceSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final health = state.health;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.backendSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(l10n.baseUrlLabel(state.baseUrl)),
                const SizedBox(height: 8),
                if (health != null)
                  Text(
                    l10n.healthSummary(
                      health.apiVersion,
                      health.status,
                      health.databaseAvailable ? l10n.healthStatusOk : l10n.healthStatusDown,
                      health.copilotServerAvailable ? l10n.healthStatusOk : l10n.healthStatusDown,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.generalConversationTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(l10n.generalConversationDescription),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.isLaunchingSession ? null : onOpenGeneralSession,
                  icon: state.isLaunchingSession
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.forum_outlined),
                  label: Text(l10n.openGeneralConversationButton),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.workspaceSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(l10n.workspaceConversationDescription),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: state.selectedWorkspaceId,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: state.workspaces
                      .map((workspace) => DropdownMenuItem<String>(value: workspace.id, child: Text('${workspace.name} • ${workspace.mountedPath}')))
                      .toList(),
                  onChanged: onWorkspaceChanged,
                ),
                if (state.errorMessage case final error?)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error, style: TextStyle(color: Colors.red.shade700)),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.selectedWorkspaceId == null || state.isLaunchingSession ? null : onOpenWorkspaceSession,
                  icon: state.isLaunchingSession
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.openWorkspaceConversationButton),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
          ],
        ),
      ),
    );
  }
}
