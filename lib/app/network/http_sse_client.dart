import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/features/auth/data/data_sources/auth_session_store.dart';

/// HTTP-based [SseClient] that opens authenticated Server-Sent Events
/// subscriptions against the backend API.
class HttpSseClient implements SseClient {
  /// Creates an [HttpSseClient].
  const HttpSseClient({
    required String baseUrl,
    required AuthSessionStore authSessionStore,
  }) : _baseUrl = baseUrl,
       _authSessionStore = authSessionStore;

  final String _baseUrl;
  final AuthSessionStore _authSessionStore;

  @override
  Stream<SseEvent> connect(String path) {
    late final StreamController<SseEvent> controller;
    HttpClient? httpClient;
    StreamSubscription<String>? linesSubscription;

    controller = StreamController<SseEvent>(
      // Define how the SSE connection is established when
      // the stream gets its first listener.
      onListen: () async {
        try {
          final session = await _authSessionStore.getSession();

          if (session == null) {
            throw const UnauthorizedException(
              message: 'Missing auth session for SSE connection',
            );
          }

          httpClient = HttpClient();

          // Build the GET request that subscribes to the backend SSE endpoint
          // (for example `/blogs/events`).
          final request = await httpClient!.getUrl(
            Uri.parse('$_baseUrl$path'),
          );

          // SSE is still plain HTTP, so authentication and content negotiation
          // are configured through regular request headers before the request
          // is sent.
          request.headers.set(
            HttpHeaders.authorizationHeader,
            'Bearer ${session.accessToken}',
          );
          // Tell the backend this request expects a Server-Sent Events stream.
          request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
          // Ask the server and any intermediaries on the request path to treat
          // this as a fresh live stream request rather than a cacheable
          // response.
          request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

          // Sending the request opens the long-lived backend stream.
          final response = await request.close();

          if (response.statusCode != HttpStatus.ok) {
            throw ServerException(
              message:
                  'SSE connection failed with status ${response.statusCode}',
            );
          }

          String? eventType;
          String? eventId;
          var dataBuffer = StringBuffer();

          // Start listening to the SSE stream, which is a stream of
          // UTF-8 encoded text lines.
          linesSubscription = response
              // decode the byte stream into UTF-8 text
              .transform(utf8.decoder)
              //splits the text stream into one line at a time.
              .transform(const LineSplitter())
              .listen(
                (line) {
                  // In SSE, a line that starts with : is a special protocol
                  // line, not a real app event field.
                  // These lines can be ignored. They are often used as
                  // keep-alive events by the backend.
                  if (line.startsWith(':')) {
                    return;
                  }

                  // A blank line marks the end of one SSE event frame. At that
                  // point the buffered `data:` lines can be decoded and
                  // emitted.
                  if (line.isEmpty) {
                    if (dataBuffer.isEmpty) {
                      eventType = null;
                      eventId = null;
                      return;
                    }

                    final decoded =
                        jsonDecode(dataBuffer.toString())
                            as Map<String, dynamic>;

                    controller.add(
                      SseEvent(
                        type: eventType,
                        id: eventId,
                        data: decoded,
                      ),
                    );

                    eventType = null;
                    eventId = null;
                    dataBuffer = StringBuffer();
                    return;
                  }

                  // `event:` provides the event name used by the backend.
                  if (line.startsWith('event:')) {
                    eventType = line.substring('event:'.length).trim();
                    return;
                  }

                  // `id:` carries the optional SSE event identifier.
                  if (line.startsWith('id:')) {
                    eventId = line.substring('id:'.length).trim();
                    return;
                  }

                  // `data:` carries the JSON payload. Multiple `data:` lines
                  // belong to the same event and must be concatenated.
                  if (line.startsWith('data:')) {
                    if (dataBuffer.isNotEmpty) {
                      dataBuffer.write('\n');
                    }
                    dataBuffer.write(line.substring('data:'.length).trim());
                  }
                },
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: true,
              );
        } on Exception catch (error, stackTrace) {
          controller.addError(error, stackTrace);
          await controller.close();
        }
      },
      onCancel: () async {
        // Closing the Dart stream should also tear down the HTTP subscription.
        await linesSubscription?.cancel();
        httpClient?.close(force: true);
      },
    );

    return controller.stream;
  }
}
