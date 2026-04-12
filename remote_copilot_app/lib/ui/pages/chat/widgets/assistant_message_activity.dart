import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/model/conversation_stream_event.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/components/animated_text_sheen.dart';
import 'package:remote_copilot_app/ui/components/copilot_markdown_view.dart';

enum AssistantActivityEntryKind { reasoning, context, tool, skill, control }

class AssistantMessageActivity {
  const AssistantMessageActivity({required this.entries});

  factory AssistantMessageActivity.fromEvents({required List<ConversationStreamEvent> events, required bool isStreaming}) {
    String reasoning = '';
    final entries = <AssistantActivityEntry>[];
    final progressiveIndices = <String, int>{};
    int? reasoningIndex;

    for (final event in events) {
      final type = event.type.toLowerCase();

      if (type.startsWith('assistant.reasoning')) {
        final chunk = _extractReasoningChunk(event);
        if (chunk != null && chunk.isNotEmpty) {
          if (type.endsWith('_delta')) {
            reasoning = _appendReasoningChunk(reasoning, chunk);
          } else {
            reasoning = chunk.trim();
          }

          if (reasoning.trim().isNotEmpty) {
            final entry = AssistantActivityEntry(kind: AssistantActivityEntryKind.reasoning, markdown: reasoning);
            if (reasoningIndex == null) {
              entries.add(entry);
              reasoningIndex = entries.length - 1;
            } else {
              entries[reasoningIndex] = entry;
            }
          }
        }

        continue;
      }

      final entry = _buildTimelineEntry(event);
      if (entry == null) {
        continue;
      }

      final progressiveKey = _resolveProgressiveKey(event, entry.kind);
      if (progressiveKey != null && progressiveIndices.containsKey(progressiveKey)) {
        entries[progressiveIndices[progressiveKey]!] = entry;
        continue;
      }

      if (progressiveKey != null) {
        progressiveIndices[progressiveKey] = entries.length;
      }

      entries.add(entry);
    }

    return AssistantMessageActivity(entries: entries);
  }

  static String _appendReasoningChunk(String current, String nextChunk) {
    final trimmedChunk = nextChunk.trim();
    if (trimmedChunk.isEmpty) {
      return current;
    }
    if (current.isEmpty) {
      return trimmedChunk;
    }

    return '$current $trimmedChunk';
  }

  static String? _extractReasoningChunk(ConversationStreamEvent event) {
    final data = event.data;
    if (data == null) {
      return null;
    }

    if (event.type.toLowerCase().endsWith('_delta')) {
      return _preferredString(data, const ['deltaContent']);
    }

    return _preferredString(data, const ['reasoning', 'content', 'deltaContent']);
  }

  final List<AssistantActivityEntry> entries;

  bool get hasContent => entries.isNotEmpty;

  String buildPreview(AppLocalizations l10n, {int maxEntries = 3}) {
    final previewEntries = entries
        .take(maxEntries)
        .map((entry) => entry.previewText(l10n))
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (previewEntries.isEmpty) {
      return l10n.assistantReasoningLabel;
    }

    final buffer = StringBuffer(previewEntries.join(' • '));
    final remaining = entries.length - previewEntries.length;
    if (remaining > 0) {
      buffer.write(' • +$remaining');
    }

    return buffer.toString();
  }

  static AssistantActivityEntry? _buildTimelineEntry(ConversationStreamEvent event) {
    final type = event.type.toLowerCase();

    if (type.startsWith('tool')) {
      return _buildToolEntry(event);
    }

    if (type.startsWith('skill') || type.contains('skills_loaded')) {
      return _buildSkillEntry(event);
    }

    if (type.startsWith('permission') || type.startsWith('user_input') || type.startsWith('elicitation') || type.startsWith('mcp')) {
      return _buildControlEntry(event);
    }

    final filePaths = _collectFilePaths(event.data);
    if (filePaths.isEmpty) {
      return null;
    }

    return AssistantActivityEntry(
      kind: AssistantActivityEntryKind.context,
      summary: _buildContextSummary(filePaths),
      details: filePaths.length > 1 ? filePaths.skip(1).toList(growable: false) : const [],
    );
  }

  static String? _resolveProgressiveKey(ConversationStreamEvent event, AssistantActivityEntryKind kind) {
    if (kind != AssistantActivityEntryKind.tool) {
      return null;
    }

    final correlationToken = _preferredString(event.data, const [
      'toolCallId',
      'tool_call_id',
      'callId',
      'call_id',
      'requestId',
      'request_id',
      'eventId',
      'event_id',
    ]);
    if (correlationToken != null) {
      return 'tool:$correlationToken';
    }

    final toolName = _preferredString(event.data, const ['toolName', 'name', 'tool', 'command']);
    final query = _preferredString(event.data, const ['query', 'pattern', 'search']);
    final firstPath = _collectFilePaths(event.data).firstOrNull;
    if (toolName == null && query == null && firstPath == null) {
      return null;
    }

    return 'tool:${toolName ?? ''}|${query ?? ''}|${firstPath ?? ''}';
  }

  static String? _preferredString(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) {
      return null;
    }

    for (final key in keys) {
      final value = data[key];
      final stringValue = _stringify(value);
      if (stringValue != null && stringValue.isNotEmpty) {
        return stringValue;
      }
    }

    return null;
  }

  static String? _stringify(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }

    return null;
  }

  static List<String> _collectFilePaths(Map<String, dynamic>? data) {
    if (data == null) {
      return const [];
    }

    final collected = <String>[];
    const preferredKeys = ['filePath', 'path', 'filePaths', 'paths', 'files', 'matchedFiles'];

    for (final key in preferredKeys) {
      _walkPotentialPaths(data[key], collected);
    }

    return collected;
  }

  static void _walkPotentialPaths(dynamic value, List<String> target) {
    if (value is String) {
      final trimmed = value.trim();
      if (_looksLikePath(trimmed) && !target.contains(trimmed)) {
        target.add(trimmed);
      }
      return;
    }

    if (value is Iterable) {
      for (final item in value) {
        _walkPotentialPaths(item, target);
      }
      return;
    }

    if (value is Map) {
      for (final nested in value.values) {
        _walkPotentialPaths(nested, target);
      }
    }
  }

  static bool _looksLikePath(String value) {
    return value.contains('/') || value.contains('\\');
  }

  static AssistantActivityEntry? _buildToolEntry(ConversationStreamEvent event) {
    final data = event.data;
    final toolName = _preferredString(data, const ['toolName', 'name', 'tool', 'command']);
    final narrative = _preferredString(data, const ['title', 'description', 'message', 'prompt']);
    final query = _preferredString(data, const ['query', 'pattern', 'search']);
    final filePaths = _collectFilePaths(data);
    final command = _preferredString(data, const ['fullCommandText', 'command']);
    final phase = _toolPhaseLabel(event.type);

    if (toolName == null && narrative == null) {
      return null;
    }

    final normalizedNarrative = narrative == null ? null : _normalizeSummary(narrative);
    final summary = switch (toolName) {
      'read_file' || 'read_package_uris' => _buildReadSummary(filePaths),
      'file_search' => query == null ? 'Searched files' : 'Searched files for "$query"',
      'grep_search' => query == null ? 'Searched workspace' : 'Searched workspace for "$query"',
      'semantic_search' => query == null ? 'Searched the codebase semantically' : 'Searched the codebase for "$query"',
      'fetch_webpage' => query == null ? 'Fetched web content' : 'Fetched web content for "$query"',
      'get_errors' => 'Checked the workspace for errors',
      'run_in_terminal' => command == null ? 'Ran a terminal command' : 'Ran "$command"',
      'apply_patch' => 'Edited workspace files',
      _ when normalizedNarrative != null && !_looksLikePath(normalizedNarrative) => normalizedNarrative,
      _ when phase != null => '${_capitalize(phase)} ${toolName ?? _humanizeType(event.type)}',
      _ => toolName ?? _humanizeType(event.type),
    };

    final details = <String>[
      if (toolName != null && !summary.toLowerCase().contains(toolName.toLowerCase())) toolName,
      if (query != null && !summary.contains(query)) 'Query: $query',
      for (final path in filePaths.where((path) => path != _extractPrimaryPath(summary))) path,
      if (narrative != null && normalizedNarrative != summary) narrative,
    ];

    return AssistantActivityEntry(kind: AssistantActivityEntryKind.tool, summary: summary, details: details);
  }

  static AssistantActivityEntry? _buildSkillEntry(ConversationStreamEvent event) {
    final data = event.data;
    final skillName = _preferredString(data, const ['skillName', 'name', 'title']);
    final narrative = _preferredString(data, const ['description', 'message', 'prompt']);

    if (skillName == null && narrative == null) {
      return null;
    }

    final normalizedNarrative = narrative == null ? null : _normalizeSummary(narrative);
    final summary = normalizedNarrative ?? (skillName == null ? _humanizeType(event.type) : 'Using $skillName');
    final details = <String>[
      if (skillName != null && !summary.toLowerCase().contains(skillName.toLowerCase())) skillName,
      if (narrative != null && normalizedNarrative != summary) narrative,
    ];

    return AssistantActivityEntry(kind: AssistantActivityEntryKind.skill, summary: summary, details: details);
  }

  static AssistantActivityEntry? _buildControlEntry(ConversationStreamEvent event) {
    final data = event.data;
    final narrative = _preferredString(data, const ['title', 'message', 'prompt', 'permission', 'name']);
    final normalizedNarrative = narrative == null ? null : _normalizeSummary(narrative);
    final permissionTarget = _preferredString(data, const ['path', 'fileName', 'fullCommandText', 'command']);
    final action = _resolvePermissionAction(data);
    final outcome = _resolvePermissionOutcome(event.type, data);

    final summary = normalizedNarrative ?? _buildPermissionSummary(action: action, outcome: outcome, target: permissionTarget);
    final details = <String>[
      if (permissionTarget != null && !summary.contains(permissionTarget)) permissionTarget,
      if (narrative != null && normalizedNarrative != summary) narrative,
    ];

    return AssistantActivityEntry(kind: AssistantActivityEntryKind.control, summary: summary, details: details);
  }

  static String? _toolPhaseLabel(String type) {
    final normalized = type.toLowerCase();
    if (normalized.endsWith('execution_start')) {
      return 'running';
    }
    if (normalized.endsWith('execution_complete')) {
      return 'completed';
    }
    if (normalized.endsWith('execution_progress') || normalized.endsWith('execution_partial_result')) {
      return 'updating';
    }
    if (normalized.endsWith('user_requested')) {
      return 'requesting';
    }

    return null;
  }

  static String _normalizeSummary(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return value;
    }

    final stripped = normalized.replaceFirst(RegExp(r'[\s\.,;:]+$'), '');
    return _capitalize(stripped.isEmpty ? normalized : stripped);
  }

  static String _humanizeType(String value) {
    return value.split(RegExp(r'[._]')).where((token) => token.isNotEmpty).map((token) => '${token[0].toUpperCase()}${token.substring(1)}').join(' ');
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static String _buildReadSummary(List<String> filePaths) {
    if (filePaths.isEmpty) {
      return 'Read file';
    }
    if (filePaths.length == 1) {
      return 'Read file ${filePaths.first}';
    }

    return 'Read ${filePaths.length} files';
  }

  static String _buildContextSummary(List<String> filePaths) {
    if (filePaths.length == 1) {
      return 'Loaded context ${filePaths.first}';
    }

    return 'Loaded ${filePaths.length} context files';
  }

  static String _extractPrimaryPath(String summary) {
    const prefix = 'Read file ';
    return summary.startsWith(prefix) ? summary.substring(prefix.length) : '';
  }

  static String _resolvePermissionAction(Map<String, dynamic>? data) {
    final target = _preferredString(data, const ['fullCommandText', 'command']);
    if (target != null && target.isNotEmpty) {
      return 'run';
    }
    if (_preferredString(data, const ['fileName']) != null) {
      return 'write';
    }

    return 'read';
  }

  static String _resolvePermissionOutcome(String eventType, Map<String, dynamic>? data) {
    if (eventType.toLowerCase().endsWith('requested')) {
      return 'requested';
    }

    final rawOutcome = _preferredString(data, const ['resultKind', 'kind', 'outcome', 'status', 'decision'])?.toLowerCase();
    if (rawOutcome == null || rawOutcome.isEmpty) {
      return 'completed';
    }
    if (rawOutcome.contains('approve')) {
      return 'granted';
    }
    if (rawOutcome.contains('deny')) {
      return 'denied';
    }

    return 'completed';
  }

  static String _buildPermissionSummary({required String action, required String outcome, String? target}) {
    final subject = switch (action) {
      'run' => target == null ? 'to run a command' : 'to run $target',
      'write' => target == null ? 'to write a file' : 'to write $target',
      _ => target == null ? 'to read a file' : 'to read $target',
    };

    return switch (outcome) {
      'requested' => 'Requested permission $subject',
      'granted' => 'Granted permission $subject',
      'denied' => 'Denied permission $subject',
      _ => 'Completed permission check $subject',
    };
  }
}

class AssistantActivityEntry {
  const AssistantActivityEntry({required this.kind, this.summary, this.details = const [], this.markdown});

  final AssistantActivityEntryKind kind;
  final String? summary;
  final List<String> details;
  final String? markdown;

  String previewText(AppLocalizations l10n) {
    if (kind == AssistantActivityEntryKind.reasoning) {
      return l10n.assistantReasoningLabel;
    }

    return summary ?? '';
  }
}

class AssistantMessageActivityView extends StatelessWidget {
  const AssistantMessageActivityView({required this.activity, required this.isStreaming, super.key});

  final AssistantMessageActivity activity;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    if (!activity.hasContent) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final preview = activity.buildPreview(l10n);

    return _ActivityTimelineTile(
      preview: preview,
      shimmer: isStreaming,
      initiallyExpanded: isStreaming,
      child: _ActivityTimelineEntries(entries: activity.entries, shimmer: isStreaming),
    );
  }
}

class _ActivityTimelineTile extends StatefulWidget {
  const _ActivityTimelineTile({required this.preview, required this.child, this.initiallyExpanded = false, this.shimmer = false});

  final String preview;
  final Widget child;
  final bool initiallyExpanded;
  final bool shimmer;

  @override
  State<_ActivityTimelineTile> createState() => _ActivityTimelineTileState();
}

class _ActivityTimelineTileState extends State<_ActivityTimelineTile> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  void didUpdateWidget(covariant _ActivityTimelineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.82);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, size: 16, color: mutedColor),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedTextSheen(
                    enabled: widget.shimmer,
                    baseColor: mutedColor,
                    child: Text(
                      widget.preview,
                      maxLines: _isExpanded ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: mutedColor, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            heightFactor: _isExpanded ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
              child: Align(alignment: Alignment.centerLeft, child: widget.child),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTimelineEntries extends StatelessWidget {
  const _ActivityTimelineEntries({required this.entries, this.shimmer = false});

  final List<AssistantActivityEntry> entries;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.45);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.take(8).length; index++) ...[
          _ActivityTimelineEntryView(entry: entries[index], shimmer: shimmer),
          if (index < entries.take(8).length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 13, bottom: 8),
              child: Container(height: 1, color: dividerColor),
            ),
        ],
      ],
    );
  }
}

class _ActivityTimelineEntryView extends StatelessWidget {
  const _ActivityTimelineEntryView({required this.entry, this.shimmer = false});

  final AssistantActivityEntry entry;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bulletColor = _colorForKind(colorScheme, entry.kind);
    final summaryColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final detailColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.64);
    final labelColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.82);
    final label = entry.kind == AssistantActivityEntryKind.reasoning ? l10n.assistantReasoningLabel : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: AnimatedTextSheen(
                      enabled: shimmer,
                      baseColor: labelColor,
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(color: labelColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (entry.markdown case final markdown?)
                  CopilotMarkdownView(data: markdown, foregroundColor: colorScheme.onSurfaceVariant, subdued: true, maxHeight: 220, sheen: shimmer)
                else if (entry.summary case final summary?) ...[
                  AnimatedTextSheen(
                    enabled: shimmer,
                    baseColor: summaryColor,
                    child: Text(
                      summary,
                      style: theme.textTheme.bodySmall?.copyWith(color: summaryColor, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                  ),
                  for (final detail in entry.details)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: AnimatedTextSheen(
                        enabled: shimmer,
                        baseColor: detailColor,
                        child: Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: detailColor, height: 1.3, fontSize: 11.5)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _colorForKind(ColorScheme colorScheme, AssistantActivityEntryKind kind) {
    return switch (kind) {
      AssistantActivityEntryKind.reasoning => colorScheme.tertiary,
      AssistantActivityEntryKind.context => colorScheme.secondary,
      AssistantActivityEntryKind.tool => colorScheme.primary,
      AssistantActivityEntryKind.skill => colorScheme.secondary,
      AssistantActivityEntryKind.control => colorScheme.error,
    };
  }
}
