// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Remote Copilot';

  @override
  String get backendUnavailable => 'No se puede conectar con el backend.';

  @override
  String get backendSectionTitle => 'Backend';

  @override
  String baseUrlLabel(Object baseUrl) {
    return 'URL base: $baseUrl';
  }

  @override
  String healthSummary(
    Object apiVersion,
    Object apiStatus,
    Object databaseStatus,
    Object copilotStatus,
  ) {
    return 'API $apiVersion • $apiStatus • BD $databaseStatus • Copilot $copilotStatus';
  }

  @override
  String get healthStatusOk => 'ok';

  @override
  String get healthStatusDown => 'caído';

  @override
  String get generalConversationTitle => 'Conversación general';

  @override
  String get generalConversationDescription =>
      'Inicia un chat remoto con Copilot sin vincularlo a ningún workspace montado.';

  @override
  String get openGeneralConversationButton => 'Abrir conversación general';

  @override
  String get workspaceSectionTitle => 'Espacio de trabajo';

  @override
  String get workspaceConversationDescription =>
      'Vincula la conversación a un workspace montado para que Copilot pueda trabajar dentro de ese repositorio.';

  @override
  String get openWorkspaceConversationButton =>
      'Abrir conversación con workspace';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get themeModeLabel => 'Modo de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get backendUrlLabel => 'URL del backend';

  @override
  String get saveButton => 'Guardar';

  @override
  String get messageInputHint => 'Escribe un mensaje';

  @override
  String get attachmentsComingSoon => 'Adjuntos próximamente';

  @override
  String get sendTooltip => 'Enviar';

  @override
  String get thinkingLabel => 'Pensando...';

  @override
  String get youLabel => 'Tú';

  @override
  String get assistantLabel => 'Copilot';

  @override
  String get assistantReasoningLabel => 'Razonando';

  @override
  String get assistantContextLabel => 'Contexto';

  @override
  String get assistantToolsLabel => 'Herramientas';

  @override
  String get assistantSkillsLabel => 'Skills';

  @override
  String get assistantControlsLabel => 'Interacciones';

  @override
  String assistantFilesCount(Object count) {
    return '$count archivos';
  }

  @override
  String assistantToolsCount(Object count) {
    return '$count herramientas';
  }

  @override
  String assistantSkillsCount(Object count) {
    return '$count skills';
  }

  @override
  String assistantInteractionsCount(Object count) {
    return '$count interacciones';
  }
}
