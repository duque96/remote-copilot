import 'package:flutter/material.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';
import 'package:remote_copilot_app/domain/model/workspace_definition.dart';
import 'package:remote_copilot_app/domain/repositories/remote_copilot_repository.dart';
import 'package:remote_copilot_app/l10n/app_localizations.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page_controller.dart';
import 'package:remote_copilot_app/ui/pages/chat/chat_page_state.dart';
import 'package:remote_copilot_app/ui/pages/chat/widgets/composer/chat_composer.dart';
import 'package:remote_copilot_app/ui/pages/chat/widgets/messages/chat_messages_list.dart';
import 'package:remote_copilot_app/ui/pages/chat/widgets/model_picker/chat_model_picker.dart';
import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_scaffold.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({required this.repository, this.sessionBundle, this.workspace, this.onOpenDrawer, super.key});

  final RemoteCopilotRepository repository;
  final WorkspaceDefinition? workspace;
  final RemoteSessionBundle? sessionBundle;
  final VoidCallback? onOpenDrawer;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _autoScrollThreshold = 120.0;

  late final ChatPageController _controller;
  late final TextEditingController _inputController;
  late final FocusNode _inputFocusNode;
  late final ScrollController _messagesScrollController;
  int _lastRenderedMessageCount = 0;
  String _lastRenderedTailSignature = '';

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputFocusNode = FocusNode();
    _messagesScrollController = ScrollController();
    _lastRenderedMessageCount = widget.sessionBundle?.conversation.messages.length ?? 0;
    _lastRenderedTailSignature = _buildTailSignature(widget.sessionBundle?.conversation.messages ?? const []);
    _controller = ChatPageController(repository: widget.repository, workspace: widget.workspace, sessionBundle: widget.sessionBundle)..initialize();
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    _inputFocusNode.dispose();
    _inputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCurrentMessage() async {
    final content = _inputController.text;
    _inputController.clear();
    await _controller.sendMessage(content);
  }

  void _maybeScrollToBottom(ChatPageState state) {
    final hasNewMessage = state.messages.length > _lastRenderedMessageCount;
    final tailSignature = _buildTailSignature(state.messages);
    final hasTailChanged = tailSignature != _lastRenderedTailSignature;

    _lastRenderedMessageCount = state.messages.length;
    _lastRenderedTailSignature = tailSignature;

    if (!hasNewMessage && !hasTailChanged) {
      return;
    }

    final isNearBottom =
        !_messagesScrollController.hasClients ||
        (_messagesScrollController.position.maxScrollExtent - _messagesScrollController.position.pixels) <= _autoScrollThreshold;
    if (!isNearBottom) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) {
        return;
      }

      final position = _messagesScrollController.position;
      _messagesScrollController.animateTo(position.maxScrollExtent, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    });
  }

  String _buildTailSignature(List<ConversationMessage> messages) {
    if (messages.isEmpty) {
      return 'empty';
    }

    final last = messages.last;
    return '${last.id}|${last.status}|${last.content.length}|${last.error ?? ''}';
  }

  void _handleModelSelected(ChatPageState state, String? value) {
    if (value == null || value == state.selectedModel || state.isSending) {
      return;
    }

    _controller.selectModel(value);
  }

  Future<void> _showModelPicker(ChatPageState state) async {
    if (state.isSending) {
      return;
    }

    final selectedModel = await showChatModelPickerSheet(
      context: context,
      availableModels: state.availableModels,
      selectedModelId: state.selectedModel,
    );

    _handleModelSelected(state, selectedModel);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final l10n = AppLocalizations.of(context)!;
        final isCompact = MediaQuery.sizeOf(context).width < 600;
        _maybeScrollToBottom(state);

        return HomeNavigationScaffold(
          onOpenDrawer: widget.onOpenDrawer,
          centerTitle: true,
          appBarTitle: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isCompact ? 190 : 240),
            child: ChatModelPickerTrigger(
              selectedModel: state.availableModels.firstWhere((model) => model.id == state.selectedModel, orElse: () => state.availableModels.first),
              enabled: !state.isSending,
              onTap: () => _showModelPicker(state),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: ChatMessagesList(
                    isLoading: state.isLoading,
                    messages: state.messages,
                    scrollController: _messagesScrollController,
                    emptyMessage: l10n.emptyConversationPrompt,
                  ),
                ),
                if (state.errorMessage case final error?)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(error, style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ),
                ChatComposer(
                  inputController: _inputController,
                  inputFocusNode: _inputFocusNode,
                  isSending: state.isSending,
                  messageHint: l10n.messageInputHint,
                  attachmentsTooltip: l10n.attachmentsComingSoon,
                  sendTooltip: l10n.sendTooltip,
                  onSend: _sendCurrentMessage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
