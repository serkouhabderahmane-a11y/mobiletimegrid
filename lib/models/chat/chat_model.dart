import '../user_model.dart';

enum MessageType {
  text,
  voice,
  file,
  image,
  deleted,
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final bool isSent;
  final bool isDelivered;
  final bool isDeleted;
  final VoiceMessageData? voiceData;
  final FileMessageData? fileData;
  final String? replyToId;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isRead = false,
    this.isSent = true,
    this.isDelivered = false,
    this.isDeleted = false,
    this.voiceData,
    this.fileData,
    this.replyToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? json['chat_id'] ?? '',
      senderId: json['senderId'] ?? json['sender_id'] ?? '',
      content: json['content'],
      type: _parseMessageType(json['type']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      isSent: json['isSent'] ?? json['is_sent'] ?? true,
      isDelivered: json['isDelivered'] ?? json['is_delivered'] ?? false,
      isDeleted: json['isDeleted'] ?? json['is_deleted'] ?? false,
      voiceData: json['voiceData'] != null 
          ? VoiceMessageData.fromJson(json['voiceData'])
          : null,
      fileData: json['fileData'] != null 
          ? FileMessageData.fromJson(json['fileData'])
          : null,
      replyToId: json['replyToId'] ?? json['reply_to_id'],
    );
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;
    switch (type.toString()) {
      case 'voice':
        return MessageType.voice;
      case 'file':
        return MessageType.file;
      case 'image':
        return MessageType.image;
      case 'deleted':
        return MessageType.deleted;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isDeleted': isDeleted,
      'voiceData': voiceData?.toJson(),
      'fileData': fileData?.toJson(),
      'replyToId': replyToId,
    };
  }
}

class VoiceMessageData {
  final String url;
  final int durationSeconds;
  final String? waveform;

  VoiceMessageData({
    required this.url,
    required this.durationSeconds,
    this.waveform,
  });

  factory VoiceMessageData.fromJson(Map<String, dynamic> json) {
    return VoiceMessageData(
      url: json['url'] ?? '',
      durationSeconds: json['durationSeconds'] ?? json['duration_seconds'] ?? 0,
      waveform: json['waveform'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'durationSeconds': durationSeconds,
      'waveform': waveform,
    };
  }
}

class FileMessageData {
  final String name;
  final int sizeBytes;
  final String mimeType;
  final String url;

  FileMessageData({
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    required this.url,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory FileMessageData.fromJson(Map<String, dynamic> json) {
    return FileMessageData(
      name: json['name'] ?? 'Unknown file',
      sizeBytes: json['sizeBytes'] ?? json['size_bytes'] ?? 0,
      mimeType: json['mimeType'] ?? json['mime_type'] ?? 'application/octet-stream',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'url': url,
    };
  }
}

class Chat {
  final String id;
  final List<User> participants;
  final String? name;
  final String? avatarUrl;
  final Message? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isGroup;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Chat({
    required this.id,
    required this.participants,
    this.name,
    this.avatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isGroup = false,
    required this.createdAt,
    this.updatedAt,
  });

  User? get otherParticipant {
    if (isGroup) return null;
    return participants.isNotEmpty ? participants.first : null;
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (isGroup) return 'Group Chat';
    return otherParticipant?.fullName ?? 'Unknown';
  }

  bool get isOnline => otherParticipant?.isOnline ?? false;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => User.fromJson(p))
          .toList() ?? [],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? json['unread_count'] ?? 0,
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,
      isGroup: json['isGroup'] ?? json['is_group'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'name': name,
      'avatarUrl': avatarUrl,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'isGroup': isGroup,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    List<User>? participants,
    String? name,
    String? avatarUrl,
    Message? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isGroup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isGroup: isGroup ?? this.isGroup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
