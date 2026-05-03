/// Domain event emitted when the backend feed stream reports a blog-related
/// feed update.
class BlogFeedEvent {
  /// Creates a [BlogFeedEvent].
  const BlogFeedEvent({
    required this.type,
    required this.blogId,
  });

  /// Type of feed event emitted by the backend.
  final BlogFeedEventType type;

  /// Identifier of the blog referenced by the event.
  final String blogId;
}

/// Supported blog feed event kinds understood by the domain layer.
enum BlogFeedEventType {
  /// Signals that the feed has newer content available.
  newBlogAvailable('feed.new_blog_available')
  ;

  /// Creates a [BlogFeedEventType] bound to its backend wire value.
  const BlogFeedEventType(this.value);

  /// Raw backend value associated with this event type.
  final String value;

  /// Converts a backend wire value into the corresponding enum case.
  static BlogFeedEventType fromValue(String value) {
    return BlogFeedEventType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw FormatException(
        'Unknown blog feed event type: $value',
      ),
    );
  }
}
