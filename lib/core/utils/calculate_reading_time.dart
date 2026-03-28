int calculateReadingTime(String content) {
  final int wordCount = content.split(RegExp(r'\s+')).length;

  final double readingTime = wordCount / 225;

  return readingTime.ceil();
}
