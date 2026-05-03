import 'dart:async';

abstract interface class SseClient {
  Stream<SseEvent> connect(String path);
}

class SseEvent {
  const SseEvent({
    required this.data,
    this.type,
    this.id,
  });

  final String? type;
  final String? id;
  final Map<String, dynamic> data;
}
