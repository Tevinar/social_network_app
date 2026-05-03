import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

void main() {
  test(
    'given a matching display value when fromValue is called then it returns '
    'the matching enum',
    () {
      final topic = BlogTopic.fromValue('Programming');

      expect(topic, BlogTopic.programming);
    },
  );

  test(
    'given an unknown value when fromValue is called then it falls back to '
    'technology',
    () {
      final topic = BlogTopic.fromValue('Unknown');

      expect(topic, BlogTopic.technology);
    },
  );
}
