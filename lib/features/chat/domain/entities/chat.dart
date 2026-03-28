import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

class Chat {
  Chat({required this.id, required this.lastMessage, required this.members});
  final String id;
  final ChatMessage lastMessage;
  final List<User> members;
}
