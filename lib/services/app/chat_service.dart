import '../../models/chat/chat_model.dart';
import '../../models/user_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api;

  ChatService(this._api);

  Future<List<Chat>> getChats() async {
    try {
      final response = await _api.get('/chats');
      final chats = (response['chats'] as List<dynamic>?)
          ?.map((c) => Chat.fromJson(c))
          .toList() ?? [];
      return chats;
    } catch (_) {
      return _getMockChats();
    }
  }

  Future<List<Chat>> getUnreadChats() async {
    try {
      final response = await _api.get('/chats?filter=unread');
      final chats = (response['chats'] as List<dynamic>?)
          ?.map((c) => Chat.fromJson(c))
          .toList() ?? [];
      return chats;
    } catch (_) {
      return _getMockChats().where((c) => c.unreadCount > 0).toList();
    }
  }

  Future<List<Chat>> getPinnedChats() async {
    try {
      final response = await _api.get('/chats?filter=pinned');
      final chats = (response['chats'] as List<dynamic>?)
          ?.map((c) => Chat.fromJson(c))
          .toList() ?? [];
      return chats;
    } catch (_) {
      return _getMockChats().where((c) => c.isPinned).toList();
    }
  }

  Future<Chat> getChat(String chatId) async {
    try {
      final response = await _api.get('/chats/$chatId');
      return Chat.fromJson(response);
    } catch (_) {
      return _getMockChats().firstWhere(
        (c) => c.id == chatId,
        orElse: () => _getMockChats().first,
      );
    }
  }

  Future<List<Message>> getMessages(String chatId, {int page = 1, int limit = 50}) async {
    try {
      final response = await _api.get('/chats/$chatId/messages?page=$page&limit=$limit');
      final messages = (response['messages'] as List<dynamic>?)
          ?.map((m) => Message.fromJson(m))
          .toList() ?? [];
      return messages;
    } catch (_) {
      return _getMockMessages(chatId);
    }
  }

  Future<Message> sendMessage(String chatId, String content, {MessageType type = MessageType.text}) async {
    try {
      final response = await _api.post('/chats/$chatId/messages', body: {
        'content': content,
        'type': type.toString().split('.').last,
      });
      return Message.fromJson(response);
    } catch (_) {
      return Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: 'current-user',
        content: content,
        type: type,
        createdAt: DateTime.now(),
        isSent: true,
        isDelivered: false,
      );
    }
  }

  Future<void> markAsRead(String chatId) async {
    try {
      await _api.post('/chats/$chatId/read');
    } catch (_) {}
  }

  Future<void> pinChat(String chatId, bool pinned) async {
    try {
      await _api.put('/chats/$chatId', body: {'isPinned': pinned});
    } catch (_) {}
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _api.delete('/chats/$chatId/messages/$messageId');
    } catch (_) {}
  }

  List<Chat> _getMockChats() {
    return [
      Chat(
        id: 'chat-1',
        participants: [
          User(
            id: 'user-1',
            firstName: 'Sophia',
            lastName: 'Carter',
            email: 'sophia@example.com',
            role: 'manager',
            isOnline: true,
          ),
        ],
        name: null,
        lastMessage: Message(
          id: 'msg-1',
          chatId: 'chat-1',
          senderId: 'user-1',
          content: 'Good morning! How was your night?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        unreadCount: 2,
        isPinned: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Chat(
        id: 'chat-2',
        participants: [
          User(
            id: 'user-2',
            firstName: 'James',
            lastName: 'Wilson',
            email: 'james@example.com',
            role: 'nurse',
            isOnline: false,
          ),
        ],
        name: null,
        lastMessage: Message(
          id: 'msg-2',
          chatId: 'chat-2',
          senderId: 'user-2',
          content: 'The patient in room 204 needs attention',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        unreadCount: 0,
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Chat(
        id: 'chat-3',
        participants: [
          User(
            id: 'user-3',
            firstName: 'Emily',
            lastName: 'Brown',
            email: 'emily@example.com',
            role: 'med_tech',
            isOnline: true,
          ),
        ],
        name: null,
        lastMessage: Message(
          id: 'msg-3',
          chatId: 'chat-3',
          senderId: 'user-3',
          content: 'Lab results are ready',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        unreadCount: 1,
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Chat(
        id: 'chat-4',
        participants: [
          User(
            id: 'user-4',
            firstName: 'Michael',
            lastName: 'Davis',
            email: 'michael@example.com',
            role: 'staff',
            isOnline: false,
          ),
        ],
        name: null,
        lastMessage: Message(
          id: 'msg-4',
          chatId: 'chat-4',
          senderId: 'current-user',
          content: 'Thanks for the update!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        unreadCount: 0,
        isPinned: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  List<Message> _getMockMessages(String chatId) {
    final now = DateTime.now();
    return [
      Message(
        id: 'msg-1',
        chatId: chatId,
        senderId: 'user-1',
        content: 'Good morning! How was your night?',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
        isSent: true,
        isDelivered: true,
      ),
      Message(
        id: 'msg-2',
        chatId: chatId,
        senderId: 'current-user',
        content: 'Good morning! It was great, thanks for asking!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 55)),
        isRead: true,
        isSent: true,
        isDelivered: true,
      ),
      Message(
        id: 'msg-3',
        chatId: chatId,
        senderId: 'user-1',
        content: 'Perfect! Don\'t forget about the team meeting at 2 PM today.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
        isSent: true,
        isDelivered: true,
      ),
      Message(
        id: 'msg-4',
        chatId: chatId,
        senderId: 'current-user',
        content: 'Got it! I\'ll be there.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 25)),
        isRead: true,
        isSent: true,
        isDelivered: true,
      ),
      Message(
        id: 'msg-5',
        chatId: chatId,
        senderId: 'user-1',
        content: 'Great! Also, can you check on patient in room 302 when you have a chance?',
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        isSent: true,
        isDelivered: true,
      ),
    ];
  }
}
