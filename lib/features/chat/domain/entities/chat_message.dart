// ignore_for_file: public_member_api_docs, sort_constructors_first

class ChatMessage {
  String id;
  String authorId;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}
