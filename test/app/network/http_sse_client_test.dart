import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/network/http_sse_client.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/network/sse/sse_event.dart';
import 'package:social_app/features/auth/data/session/auth_token_manager.dart';

class MockAuthTokenManager extends Mock implements AuthTokenManager {}

void main() {
  late MockAuthTokenManager authTokenManager;
  late HttpServer server;

  setUp(() async {
    authTokenManager = MockAuthTokenManager();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });

  tearDown(() async {
    await server.close(force: true);
  });

  String baseUrl() => 'http://${server.address.host}:${server.port}';

  group('connect', () {
    test(
      'given no auth token when connecting then emits UnauthorizedException',
      () async {
        // Arrange
        final client = HttpSseClient(
          baseUrl: baseUrl(),
          authTokenManager: authTokenManager,
        );
        when(
          () => authTokenManager.getValidAccessToken(),
        ).thenAnswer((_) async => null);

        // Assert
        await expectLater(
          client.connect('/events'),
          emitsError(
            isA<UnauthorizedException>().having(
              (value) => value.message,
              'message',
              'Missing auth session for SSE connection',
            ),
          ),
        );
      },
    );

    test(
      'given a successful SSE response when connecting then parses and emits '
      'events',
      () async {
        // Arrange
        final requestHandled = Completer<void>();
        late String? authorizationHeader;
        late String? acceptHeader;
        late String? cacheControlHeader;

        server.listen((request) async {
          authorizationHeader = request.headers.value(
            HttpHeaders.authorizationHeader,
          );
          acceptHeader = request.headers.value(HttpHeaders.acceptHeader);
          cacheControlHeader = request.headers.value(
            HttpHeaders.cacheControlHeader,
          );

          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType(
            'text',
            'event-stream',
            charset: 'utf-8',
          );
          request.response.write(': keep-alive\n');
          request.response.write('\n');
          request.response.write('event: chat.message\n');
          request.response.write('id: 42\n');
          request.response.write('data: {"type":"message",\n');
          request.response.write('data: "value":1}\n');
          request.response.write('\n');
          await request.response.flush();
          await request.response.close();
          requestHandled.complete();
        });

        final client = HttpSseClient(
          baseUrl: baseUrl(),
          authTokenManager: authTokenManager,
        );
        when(
          () => authTokenManager.getValidAccessToken(),
        ).thenAnswer((_) async => 'access-token');

        // Act
        final event = await client.connect('/events').first;
        await requestHandled.future;

        // Assert
        expect(
          event,
          isA<SseEvent>()
              .having((value) => value.type, 'type', 'chat.message')
              .having((value) => value.id, 'id', '42')
              .having(
                (value) => value.data,
                'data',
                <String, dynamic>{'type': 'message', 'value': 1},
              ),
        );
        expect(authorizationHeader, 'Bearer access-token');
        expect(acceptHeader, 'text/event-stream');
        expect(cacheControlHeader, 'no-cache');
      },
    );

    test(
      'given a non-200 SSE response when connecting then emits ServerException',
      () async {
        // Arrange
        server.listen((request) async {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            '{"statusCode":403,"code":"forbidden","message":"Forbidden",'
            '"path":"/events","timestamp":"2026-05-12T10:00:00.000Z"}',
          );
          await request.response.close();
        });

        final client = HttpSseClient(
          baseUrl: baseUrl(),
          authTokenManager: authTokenManager,
        );
        when(
          () => authTokenManager.getValidAccessToken(),
        ).thenAnswer((_) async => 'access-token');

        // Assert
        await expectLater(
          client.connect('/events'),
          emitsError(
            isA<ServerException>()
                .having((value) => value.message, 'message', 'Forbidden')
                .having((value) => value.code, 'code', 'forbidden')
                .having((value) => value.statusCode, 'statusCode', 403)
                .having((value) => value.path, 'path', '/events'),
          ),
        );
      },
    );
  });
}
