/// One parsed Server-Sent Events frame.
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
