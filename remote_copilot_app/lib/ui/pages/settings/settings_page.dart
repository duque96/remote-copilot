import 'package:flutter/material.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';

class SettingsPageResult {
  const SettingsPageResult({required this.baseUrl, required this.themeMode});

  final String baseUrl;
  final ThemeMode themeMode;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.initialBaseUrl, required this.initialThemeMode, super.key});

  final String initialBaseUrl;
  final ThemeMode initialThemeMode;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _controller;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBaseUrl);
    _themeMode = widget.initialThemeMode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.themeModeLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text(l10n.themeModeSystem)),
              ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text(l10n.themeModeLight)),
              ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text(l10n.themeModeDark)),
            ],
            selected: {_themeMode},
            onSelectionChanged: (selection) {
              setState(() {
                _themeMode = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.backendUrlLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'http://localhost:8080'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(SettingsPageResult(baseUrl: _controller.text.trim(), themeMode: _themeMode)),
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }
}
