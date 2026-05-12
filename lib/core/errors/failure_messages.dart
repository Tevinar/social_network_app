// Client-owned user-facing failure messages shared across use cases and
// backend error mapping.
//
// Centralizing these strings keeps the UX consistent when the same business
// rule can be enforced locally before a request or remotely by the backend.

/// Common messages reused across multiple features.
abstract final class CommonFailureMessages {
  /// Message used when a list-size limit is invalid.
  static const invalidLimit = 'Limit must be greater than zero';

  /// Message used when the submitted request data is invalid in a generic way.
  static const invalidRequest =
      'The submitted data is invalid. Please review and try again.';

  /// Message used when a pagination cursor is invalid or expired.
  static const invalidCursor =
      'Unable to load more items. Please refresh and try again.';

  /// Message used for generic request conflicts that do not have a more
  /// specific client-owned message.
  static const conflict =
      'This request conflicts with existing data. Please try again.';
}

/// Authentication-related messages owned by the client.
abstract final class AuthFailureMessages {
  /// Message used when an email address is invalid.
  static const invalidEmail = 'Please enter a valid email address.';

  /// Message used when the password does not satisfy client rules.
  static const invalidPassword = 'Password must be at least 6 characters long.';

  /// Message used when the submitted credentials are rejected.
  static const invalidCredentials = 'Invalid email or password.';

  /// Message used when the submitted email is already registered.
  static const emailAlreadyInUse = 'Email already in use.';

  /// Message used when the submitted display name is invalid.
  static const invalidName = 'Please enter a valid name.';

  /// Message used when the local device identifier is invalid.
  static const invalidDeviceId =
      'Unable to validate this device. Please try again.';

  /// Message used when the account is already signed in on this device.
  static const alreadySignedInOnDevice =
      'This account is already signed in on this device.';
}

/// Blog-related messages owned by the client.
abstract final class BlogFailureMessages {
  /// Message used when no image was provided.
  static const imageRequired = 'Image cannot be empty';

  /// Message used when the title is empty.
  static const titleRequired = 'Title cannot be empty';

  /// Message used when the content is empty.
  static const contentRequired = 'Content cannot be empty';

  /// Message used when no topic is selected.
  static const topicSelectionRequired = 'At least one topic must be selected';
}

/// Chat-related messages owned by the client.
abstract final class ChatFailureMessages {
  /// Message used when no chat member is selected.
  static const memberSelectionRequired =
      'At least one chat member must be selected';

  /// Message used when the first message content is empty.
  static const firstMessageContentRequired =
      'First message content cannot be empty';

  /// Message used when a regular chat message content is empty.
  static const messageContentRequired = 'Message content cannot be empty';

  /// Message used when the submitted members are invalid.
  static const invalidMembers = 'Please select valid chat members.';

  /// Message used when the submitted message content is invalid.
  static const invalidMessageContent = 'Please enter a valid message.';
}
