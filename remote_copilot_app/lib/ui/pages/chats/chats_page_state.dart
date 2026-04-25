import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';

enum ChatsPageStatus { loading, ready, failure }

class ChatsPageState {
  const ChatsPageState({required this.status, required this.searchQuery, this.items = const [], this.errorMessage});

  const ChatsPageState.initial() : status = ChatsPageStatus.loading, searchQuery = '', items = const [], errorMessage = null;

  final ChatsPageStatus status;
  final String searchQuery;
  final List<ChatHistoryItem> items;
  final String? errorMessage;

  List<ChatHistoryItem> get filteredItems {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items
        .where((item) {
          return item.title.toLowerCase().contains(normalizedQuery) || item.preview.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  ChatsPageState copyWith({ChatsPageStatus? status, String? searchQuery, List<ChatHistoryItem>? items, Object? errorMessage = _unset}) {
    return ChatsPageState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  static const _unset = Object();
}

class ChatHistoryItem {
  const ChatHistoryItem({required this.id, required this.title, required this.preview, required this.workspaceId});

  factory ChatHistoryItem.fromSession(RemoteSession session) {
    return ChatHistoryItem(id: session.id, title: session.title, preview: '', workspaceId: session.workspaceId);
  }

  final String id;
  final String title;
  final String preview;
  final String? workspaceId;
}
