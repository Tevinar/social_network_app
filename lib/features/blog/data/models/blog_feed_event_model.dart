import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/core/serialization/json_reader.dart';

/// Data-layer representation of one blog feed event received over SSE.
class BlogFeedEventModel {
  /// Creates a [BlogFeedEventModel].
  BlogFeedEventModel({
    required this.type,
    required this.blogId,
  });

  /// Builds a blog feed event model from one parsed SSE event.
  factory BlogFeedEventModel.fromSseEvent(SseEvent event) {
    return BlogFeedEventModel(
      type: event.type!,
      blogId: JsonReader.readString(event.data, 'blogId'),
    );
  }

  /// Event name emitted by the backend feed stream.
  final String type;

  /// Identifier of the blog referenced by the event.
  final String blogId;
}
