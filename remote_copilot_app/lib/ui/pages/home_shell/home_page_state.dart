import 'package:remote_copilot_app/ui/pages/home_shell/navigation/home_navigation_drawer.dart';
import 'package:remote_copilot_app/domain/model/remote_session_bundle.dart';

enum HomePageStatus { loading, ready, failure }

class HomePageState {
  static const _unset = Object();

  const HomePageState({
    required this.status,
    required this.baseUrl,
    required this.selectedSection,
    required this.chatInstanceSeed,
    required this.chatsRefreshSeed,
    required this.activeSessionBundle,
    this.errorMessage,
  });

  const HomePageState.initial()
    : status = HomePageStatus.loading,
      baseUrl = '',
      selectedSection = ChatNavigationDrawerItem.newConversation,
      chatInstanceSeed = 0,
      chatsRefreshSeed = 0,
      activeSessionBundle = null,
      errorMessage = null;

  final HomePageStatus status;
  final String baseUrl;
  final ChatNavigationDrawerItem selectedSection;
  final int chatInstanceSeed;
  final int chatsRefreshSeed;
  final RemoteSessionBundle? activeSessionBundle;
  final String? errorMessage;

  HomePageState copyWith({
    HomePageStatus? status,
    String? baseUrl,
    ChatNavigationDrawerItem? selectedSection,
    int? chatInstanceSeed,
    int? chatsRefreshSeed,
    Object? activeSessionBundle = _unset,
    Object? errorMessage = _unset,
  }) {
    return HomePageState(
      status: status ?? this.status,
      baseUrl: baseUrl ?? this.baseUrl,
      selectedSection: selectedSection ?? this.selectedSection,
      chatInstanceSeed: chatInstanceSeed ?? this.chatInstanceSeed,
      chatsRefreshSeed: chatsRefreshSeed ?? this.chatsRefreshSeed,
      activeSessionBundle: activeSessionBundle == _unset ? this.activeSessionBundle : activeSessionBundle as RemoteSessionBundle?,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}
