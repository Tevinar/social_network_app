import 'dart:async';

/// Client abstraction for opening Server-Sent Events streams.
abstract interface class SseClient {
  /// Connects to the SSE endpoint identified by [path].
  Stream<SseEvent> connect(String path);
}

/// One parsed event frame emitted by an [SseClient].
class SseEvent {
  /// Creates an [SseEvent].
  const SseEvent({
    required this.data,
    this.type,
    this.id,
  });

  /// Optional event name declared by the backend.
  final String? type;

  /// Optional SSE event identifier.
  final String? id;

  /// Decoded JSON payload carried by the `data:` lines.
  final Map<String, dynamic> data;
}
