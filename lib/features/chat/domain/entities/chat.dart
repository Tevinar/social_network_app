import 'package:social_network_app/features/auth/domain/entities/user.dart';
import 'package:social_network_app/features/chat/domain/entities/chat_message.dart';

class Chat {
  final String id;
  final ChatMessage lastMessage;
  final List<User> members;

  Chat({required this.id, required this.lastMessage, required this.members});
}
