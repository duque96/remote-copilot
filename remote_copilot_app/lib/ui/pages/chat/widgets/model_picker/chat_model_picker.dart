import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';

String buildCopilotModelLabel(CopilotModelOption model) {
  final multiplier = model.multiplier;
  if (multiplier == null) {
    return model.name;
  }

  final formattedMultiplier = multiplier == multiplier.roundToDouble()
      ? multiplier.toStringAsFixed(0)
      : multiplier.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

  return '${model.name} (x$formattedMultiplier)';
}

Future<String?> showChatModelPickerSheet({
  required BuildContext context,
  required List<CopilotModelOption> availableModels,
  required String selectedModelId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    enableDrag: true,
    isScrollControlled: true,
    builder: (context) => ChatModelPickerSheet(availableModels: availableModels, selectedModelId: selectedModelId),
  );
}

class ChatModelPickerTrigger extends StatelessWidget {
  const ChatModelPickerTrigger({required this.selectedModel, required this.onTap, this.enabled = true, super.key});

  final CopilotModelOption selectedModel;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  buildCopilotModelLabel(selectedModel),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatModelPickerSheet extends StatelessWidget {
  const ChatModelPickerSheet({required this.availableModels, required this.selectedModelId, super.key});

  final List<CopilotModelOption> availableModels;
  final String selectedModelId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final model in availableModels)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Text(buildCopilotModelLabel(model), style: theme.textTheme.titleMedium),
                trailing: model.id == selectedModelId ? Icon(Icons.check_rounded, color: theme.colorScheme.primary) : null,
                onTap: () => Navigator.of(context).pop(model.id),
              ),
          ],
        ),
      ),
    );
  }
}
