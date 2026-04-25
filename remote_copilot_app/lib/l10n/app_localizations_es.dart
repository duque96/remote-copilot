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
  String get projectsHeroTitle => 'Trabaja sobre tus proyectos';

  @override
  String get projectsHeroDescription =>
      'Gestiona carpetas de proyecto, sincroniza el catálogo y abre sesiones remotas de Copilot sobre cualquier repositorio montado.';

  @override
  String projectsCountLabel(Object count) {
    return '$count proyectos activos';
  }

  @override
  String selectedProjectLabel(Object projectName) {
    return 'Proyecto activo: $projectName';
  }

  @override
  String get selectedProjectFallbackLabel =>
      'Selecciona un proyecto para centrar el trabajo';

  @override
  String get generalModeLabel => 'O usa el modo general para ideación rápida';

  @override
  String get projectCatalogTitle => 'Catálogo de proyectos';

  @override
  String get projectCatalogDescription =>
      'Cada carpeta hija de la raíz montada vive aquí como un proyecto independiente con su propia sesión de Copilot.';

  @override
  String get projectCatalogVisualDescription =>
      'Gestionando entornos remotos persistentes';

  @override
  String get commandProjectsLabel => 'Proyectos';

  @override
  String get commandDeployLabel => 'Despliegue';

  @override
  String get cpuLoadLabel => 'Carga CPU';

  @override
  String get ramUsageLabel => 'Uso RAM';

  @override
  String get activeNodesLabel => 'Nodos activos';

  @override
  String get latencyLabel => 'Latencia';

  @override
  String get createProjectTitle => 'Crear proyecto';

  @override
  String get createProjectAction => 'Crear proyecto';

  @override
  String get renameProjectTitle => 'Editar proyecto';

  @override
  String get renameProjectAction => 'Guardar cambios';

  @override
  String get deleteProjectAction => 'Borrar proyecto';

  @override
  String get syncProjectsAction => 'Sincronizar proyectos';

  @override
  String get projectNameLabel => 'Nombre del proyecto';

  @override
  String get projectNameHint => 'mi-proyecto';

  @override
  String get projectPathLabel => 'Carpeta montada';

  @override
  String get emptyProjectsTitle => 'Todavía no hay proyectos';

  @override
  String get emptyProjectsDescription =>
      'Crea una carpeta nueva dentro de la raíz montada o sincroniza para cargar las que ya existan.';

  @override
  String get noFilteredProjectsTitle => 'No hay coincidencias';

  @override
  String get noFilteredProjectsDescription =>
      'Ajusta la búsqueda o cambia el filtro para volver a mostrar proyectos.';

  @override
  String get searchProjectsHint => 'Buscar por nombre o ruta';

  @override
  String get filterAllProjectsLabel => 'Todos';

  @override
  String get filterActiveProjectsLabel => 'Activos';

  @override
  String get filterAttentionProjectsLabel => 'Revisar';

  @override
  String projectLastUsedLabel(Object date) {
    return 'Último uso: $date';
  }

  @override
  String projectNeverUsedLabel(Object date) {
    return 'Creado: $date';
  }

  @override
  String get projectStatusActive => 'Activo';

  @override
  String get projectStatusIdle => 'En espera';

  @override
  String get projectStatusAttention => 'Requiere revisión';

  @override
  String deleteProjectTitle(Object projectName) {
    return 'Borrar $projectName';
  }

  @override
  String deleteProjectMessage(Object projectPath) {
    return 'Se eliminará la carpeta del proyecto en $projectPath y dejará de aparecer en la app.';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get generalConversationTitle => 'Conversación general';

  @override
  String get generalConversationDescription =>
      'Inicia un chat remoto con Copilot sin vincularlo a ningún proyecto. Es útil para explorar ideas o preparar trabajo antes de entrar en un repositorio.';

  @override
  String get generalConversationFeatureTitle => 'Ideal para aterrizar ideas';

  @override
  String get generalConversationFeatureDescription =>
      'Úsalo para pedir estrategia, diseñar cambios o preparar prompts antes de entrar en un proyecto concreto.';

  @override
  String get openGeneralConversationButton => 'Abrir conversación general';

  @override
  String get workspaceSectionTitle => 'Proyecto';

  @override
  String get workspaceConversationDescription =>
      'Vincula la conversación a un proyecto montado para que Copilot pueda trabajar dentro de ese repositorio.';

  @override
  String get openWorkspaceConversationButton =>
      'Abrir conversación con proyecto';

  @override
  String get openProjectConversationButton => 'Abrir chat del proyecto';

  @override
  String get newConversationLabel => 'Nueva conversación';

  @override
  String get chatsLabel => 'Chats';

  @override
  String get chatsPageTitle => 'Chats';

  @override
  String get chatsSearchHint => 'Buscar chats';

  @override
  String get chatsEmptyTitle => 'Todavía no hay historial de chats';

  @override
  String get chatsEmptyDescription =>
      'Tus conversaciones anteriores aparecerán aquí cuando el backend exponga el historial de chats.';

  @override
  String get deleteChatHistoryAction => 'Borrar chat';

  @override
  String deleteChatHistoryTitle(Object chatTitle) {
    return 'Borrar $chatTitle';
  }

  @override
  String get deleteChatHistoryMessage =>
      'Este chat desaparecerá del histórico y se eliminarán sus mensajes persistidos.';

  @override
  String get streamingTelemetryLabel => 'Telemetría en streaming';

  @override
  String get projectsRootHint =>
      'La app gestiona proyectos como carpetas hijas dentro de la raíz montada del backend.';

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
  String get emptyConversationPrompt => '¿En qué puedo ayudarte?';

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
