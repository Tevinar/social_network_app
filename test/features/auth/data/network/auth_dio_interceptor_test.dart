import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/features/auth/data/network/auth_dio_interceptor.dart';
import 'package:social_app/features/auth/data/session/auth_token_manager.dart';

class MockDio extends Mock implements Dio {}

class MockAuthTokenManager extends Mock implements AuthTokenManager {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockDio dio;
  late MockAuthTokenManager authTokenManager;
  late MockRequestInterceptorHandler requestHandler;
  late MockErrorInterceptorHandler errorHandler;
  late AuthDioInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/fallback'));
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/fallback')),
    );
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/fallback')),
    );
  });

  setUp(() {
    dio = MockDio();
    authTokenManager = MockAuthTokenManager();
    requestHandler = MockRequestInterceptorHandler();
    errorHandler = MockErrorInterceptorHandler();
    interceptor = AuthDioInterceptor(
      dio: dio,
      authTokenManager: authTokenManager,
    );

    when(() => requestHandler.next(any())).thenReturn(null);
    when(() => requestHandler.reject(any())).thenReturn(null);
    when(() => errorHandler.next(any())).thenReturn(null);
    when(() => errorHandler.resolve(any())).thenReturn(null);
  });

  group('onRequest', () {
    test(
      'given a valid access token when a request starts then adds a bearer '
      'header',
      () async {
        // Arrange
        final options = RequestOptions(path: '/protected');
        when(
          () => authTokenManager.getValidAccessToken(),
        ).thenAnswer((_) async => 'access-token');

        // Act
        await interceptor.onRequest(options, requestHandler);

        // Assert
        expect(
          options.headers[HttpHeaders.authorizationHeader],
          'Bearer access-token',
        );
        verify(() => requestHandler.next(options)).called(1);
        verifyNever(() => requestHandler.reject(any()));
      },
    );

    test(
      'given no valid access token when a request starts then rejects the '
      'request',
      () async {
        // Arrange
        final options = RequestOptions(path: '/protected');
        when(
          () => authTokenManager.getValidAccessToken(),
        ).thenAnswer((_) async => null);

        // Act
        await interceptor.onRequest(options, requestHandler);

        // Assert
        final error =
            verify(
                  () => requestHandler.reject(captureAny()),
                ).captured.single
                as DioException;

        expect(
          error.error,
          isA<HttpException>().having(
            (value) => value.message,
            'message',
            'Missing auth session',
          ),
        );
        verifyNever(() => requestHandler.next(any()));
      },
    );
  });

  group('onError', () {
    test(
      'given a 401 response when token refresh succeeds then retries the '
      'request once',
      () async {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/protected',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer stale-access-token',
          },
        );
        final error = DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 401,
          ),
        );

        when(
          () => authTokenManager.forceRefreshAccessToken(),
        ).thenAnswer((_) async => 'fresh-access-token');
        when(
          () => dio.fetch<dynamic>(any()),
        ).thenAnswer((invocation) async {
          final retriedOptions =
              invocation.positionalArguments.single as RequestOptions;

          return Response<dynamic>(
            requestOptions: retriedOptions,
            statusCode: 200,
            data: <String, dynamic>{'ok': true},
          );
        });

        // Act
        await interceptor.onError(error, errorHandler);

        // Assert
        final retriedOptions =
            verify(
                  () => dio.fetch<dynamic>(captureAny()),
                ).captured.single
                as RequestOptions;

        expect(
          retriedOptions.headers[HttpHeaders.authorizationHeader],
          'Bearer fresh-access-token',
        );
        expect(retriedOptions.extra['auth_retry_done'], isTrue);
        verify(() => errorHandler.resolve(any())).called(1);
        verifyNever(() => errorHandler.next(any()));
      },
    );

    test(
      'given a request already retried when another 401 arrives then forwards '
      'the original error',
      () async {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/protected',
          extra: const {'auth_retry_done': true},
        );
        final error = DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 401,
          ),
        );

        // Act
        await interceptor.onError(error, errorHandler);

        // Assert
        verifyNever(() => authTokenManager.forceRefreshAccessToken());
        verify(() => errorHandler.next(error)).called(1);
      },
    );
  });
}
