/// Represents a blog topic
enum BlogTopic {
  /// Technology topic
  technology('Technology'),

  /// Business topic
  business('Business'),

  /// Programming topic
  programming('Programming'),

  /// Entertainment topic
  entertainment('Entertainment')
  ;

  const BlogTopic(this.value);

  /// The string value of the topic
  final String value;

  /// Creates a [BlogTopic] from a string value.
  static BlogTopic fromValue(String value) {
    return BlogTopic.values.firstWhere(
      (topic) => topic.value == value,
      orElse: () => throw FormatException(
        'Unknown blog topic: $value',
      ),
    );
  }
}
