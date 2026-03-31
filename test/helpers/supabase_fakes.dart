import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Mutable<T> {
  _Mutable(this.value);

  T value;
}

mixin FutureDelegate<T> implements Future<T> {
  Future<T> get future;

  @override
  Stream<T> asStream() => future.asStream();

  @override
  Future<T> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) => future.catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) => future.then(onValue, onError: onError);

  @override
  Future<T> timeout(
    Duration timeLimit, {
    FutureOr<T> Function()? onTimeout,
  }) => future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      future.whenComplete(action);
}

class FakeCountResponseBuilder<T> extends Fake
    with FutureDelegate<PostgrestResponse<T>>
    implements ResponsePostgrestBuilder<PostgrestResponse<T>, T, T> {
  FakeCountResponseBuilder(this.response);

  final PostgrestResponse<T> response;

  @override
  Future<PostgrestResponse<T>> get future => Future.value(response);
}

class FakeMapBuilder extends Fake
    with FutureDelegate<PostgrestMap>
    implements PostgrestTransformBuilder<PostgrestMap> {
  FakeMapBuilder(this.map);

  final PostgrestMap map;

  @override
  Future<PostgrestMap> get future => Future.value(map);
}

class FakeIntBuilder extends Fake
    with FutureDelegate<int>
    implements PostgrestFilterBuilder<int> {
  FakeIntBuilder(this.result);

  final int result;
  final _countOption = _Mutable<CountOption?>(null);

  CountOption? get countOption => _countOption.value;

  set countOption(CountOption? value) => _countOption.value = value;

  @override
  Future<int> get future => Future.value(result);
}

class FakeValueBuilder<T> extends Fake
    with FutureDelegate<T>
    implements PostgrestFilterBuilder<T> {
  FakeValueBuilder(this.value);

  final T value;

  @override
  Future<T> get future => Future.value(value);
}

class FakeListBuilder extends Fake
    with FutureDelegate<PostgrestList>
    implements
        PostgrestFilterBuilder<PostgrestList>,
        PostgrestTransformBuilder<PostgrestList> {
  FakeListBuilder({
    required this.result,
    this.singleResult,
    this.countResponse,
  });

  final PostgrestList result;
  final PostgrestMap? singleResult;
  final PostgrestResponse<PostgrestList>? countResponse;
  final _selectedColumns = _Mutable<String?>(null);
  final _rangeFrom = _Mutable<int?>(null);
  final _rangeTo = _Mutable<int?>(null);
  final _orderColumn = _Mutable<String?>(null);
  final _orderAscending = _Mutable<bool?>(null);
  final _eqColumn = _Mutable<String?>(null);
  final _eqValue = _Mutable<Object?>(null);

  String? get selectedColumns => _selectedColumns.value;

  set selectedColumns(String? value) => _selectedColumns.value = value;

  int? get rangeFrom => _rangeFrom.value;

  set rangeFrom(int? value) => _rangeFrom.value = value;

  int? get rangeTo => _rangeTo.value;

  set rangeTo(int? value) => _rangeTo.value = value;

  String? get orderColumn => _orderColumn.value;

  set orderColumn(String? value) => _orderColumn.value = value;

  bool? get orderAscending => _orderAscending.value;

  set orderAscending(bool? value) => _orderAscending.value = value;

  String? get eqColumn => _eqColumn.value;

  set eqColumn(String? value) => _eqColumn.value = value;

  Object? get eqValue => _eqValue.value;

  set eqValue(Object? value) => _eqValue.value = value;

  @override
  Future<PostgrestList> get future => Future.value(result);

  @override
  PostgrestTransformBuilder<PostgrestList> range(
    int from,
    int to, {
    String? referencedTable,
  }) {
    rangeFrom = from;
    rangeTo = to;
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestList> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    orderColumn = column;
    orderAscending = ascending;
    return this;
  }

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) {
    eqColumn = column;
    eqValue = value;
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    selectedColumns = columns;
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return FakeMapBuilder(singleResult ?? result.first);
  }

  @override
  ResponsePostgrestBuilder<
    PostgrestResponse<PostgrestList>,
    PostgrestList,
    PostgrestList
  >
  count([CountOption count = CountOption.exact]) {
    return FakeCountResponseBuilder<PostgrestList>(
      countResponse ?? PostgrestResponse(data: result, count: result.length),
    );
  }
}

class FakeInsertBuilder extends Fake
    with FutureDelegate<dynamic>
    implements PostgrestFilterBuilder<dynamic> {
  FakeInsertBuilder(this.listBuilder);

  final FakeListBuilder listBuilder;
  final _insertedValues = _Mutable<Object?>(null);

  Object? get insertedValues => _insertedValues.value;

  set insertedValues(Object? value) => _insertedValues.value = value;

  @override
  Future<dynamic> get future => Future.value();

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    listBuilder.selectedColumns = columns;
    return listBuilder;
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder({
    required this.selectBuilder,
    required this.insertBuilder,
    required this.countBuilder,
  });

  final FakeListBuilder selectBuilder;
  final FakeInsertBuilder insertBuilder;
  final FakeIntBuilder countBuilder;
  final _selectedColumns = _Mutable<String?>(null);
  final _countOption = _Mutable<CountOption?>(null);

  String? get selectedColumns => _selectedColumns.value;

  set selectedColumns(String? value) => _selectedColumns.value = value;

  CountOption? get countOption => _countOption.value;

  set countOption(CountOption? value) => _countOption.value = value;

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    selectedColumns = columns;
    selectBuilder.selectedColumns = columns;
    return selectBuilder;
  }

  @override
  PostgrestFilterBuilder<dynamic> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    insertBuilder.insertedValues = values;
    return insertBuilder;
  }

  @override
  PostgrestFilterBuilder<int> count([
    CountOption option = CountOption.exact,
  ]) {
    countOption = option;
    countBuilder.countOption = option;
    return countBuilder;
  }
}

class FakeStorageFileApi extends Fake implements StorageFileApi {
  String? uploadPath;
  File? uploadedFile;
  String? publicUrlPath;
  String uploadResult = 'uploaded/key';
  String publicUrlResult = 'https://public-url';

  @override
  Future<String> upload(
    String path,
    File file, {
    FileOptions fileOptions = const FileOptions(),
    int? retryAttempts,
    StorageRetryController? retryController,
  }) async {
    uploadPath = path;
    uploadedFile = file;
    return uploadResult;
  }

  @override
  String getPublicUrl(String path, {TransformOptions? transform}) {
    publicUrlPath = path;
    return publicUrlResult;
  }
}

class FakeSupabaseStorageClient extends Fake implements SupabaseStorageClient {
  String? bucketId;
  FakeStorageFileApi fileApi = FakeStorageFileApi();

  @override
  StorageFileApi from(String id) {
    bucketId = id;
    return fileApi;
  }
}

class FakeRealtimeChannel extends Fake implements RealtimeChannel {
  PostgresChangeEvent? event;
  String? schema;
  String? table;
  PostgresChangeFilter? filter;
  void Function(PostgresChangePayload payload)? postgresCallback;
  bool subscribed = false;
  bool unsubscribed = false;

  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    required void Function(PostgresChangePayload payload) callback,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
  }) {
    this.event = event;
    this.schema = schema;
    this.table = table;
    this.filter = filter;
    postgresCallback = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) {
    subscribed = true;
    return this;
  }

  @override
  Future<String> unsubscribe([Duration? timeout]) async {
    unsubscribed = true;
    return 'ok';
  }

  void emit(PostgresChangePayload payload) {
    postgresCallback?.call(payload);
  }
}

class FakeRealtimeClient extends Fake implements RealtimeClient {
  FakeRealtimeClient(this.channelInstance);

  final FakeRealtimeChannel channelInstance;
  String? topic;

  @override
  RealtimeChannel channel(
    String topic, [
    RealtimeChannelConfig params = const RealtimeChannelConfig(),
  ]) {
    this.topic = topic;
    return channelInstance;
  }
}
