import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:remote_copilot_app/core/theme/app_theme.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/core/config/app_defaults.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/repositories/http_remote_copilot_repository.dart';
import 'package:remote_copilot_app/infrastructure/services/api_client.dart';
import 'package:remote_copilot_app/infrastructure/services/settings_service.dart';
import 'package:remote_copilot_app/infrastructure/services/sse_client.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/home_page.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final settingsService = SharedPreferencesSettingsService();
  final themeMode = await settingsService.loadThemeMode();

  final httpClient = http.Client();
  final apiClient = ApiClient(client: httpClient, sseClient: SseClient(httpClient), baseUrl: AppDefaults.defaultApiBaseUrl);

  // Quitamos la pantalla de splash
  FlutterNativeSplash.remove();

  runApp(RemoteCopilotApp(repository: HttpRemoteCopilotRepository(apiClient), settingsService: settingsService, initialThemeMode: themeMode));
}

class RemoteCopilotApp extends StatefulWidget {
  const RemoteCopilotApp({required this.repository, required this.settingsService, required this.initialThemeMode, super.key});

  final RemoteCopilotRepository repository;
  final SettingsService settingsService;
  final ThemeMode initialThemeMode;

  @override
  State<RemoteCopilotApp> createState() => _RemoteCopilotAppState();
}

class _RemoteCopilotAppState extends State<RemoteCopilotApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _updateThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    await widget.settingsService.saveThemeMode(themeMode);

    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme(TextTheme()).light(),
      darkTheme: AppTheme(TextTheme()).dark(),
      themeMode: _themeMode,
      home: HomePage(
        repository: widget.repository,
        settingsService: widget.settingsService,
        currentThemeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}
