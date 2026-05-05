// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedBlogsTable extends CachedBlogs
    with TableInfo<$CachedBlogsTable, CachedBlog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBlogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterIdMeta = const VerificationMeta(
    'posterId',
  );
  @override
  late final GeneratedColumn<String> posterId = GeneratedColumn<String>(
    'poster_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicsJsonMeta = const VerificationMeta(
    'topicsJson',
  );
  @override
  late final GeneratedColumn<String> topicsJson = GeneratedColumn<String>(
    'topics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterNameMeta = const VerificationMeta(
    'posterName',
  );
  @override
  late final GeneratedColumn<String> posterName = GeneratedColumn<String>(
    'poster_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    posterId,
    title,
    content,
    imageUrl,
    topicsJson,
    createdAt,
    updatedAt,
    posterName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_blogs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBlog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poster_id')) {
      context.handle(
        _posterIdMeta,
        posterId.isAcceptableOrUnknown(data['poster_id']!, _posterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_posterIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('topics_json')) {
      context.handle(
        _topicsJsonMeta,
        topicsJson.isAcceptableOrUnknown(data['topics_json']!, _topicsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_topicsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('poster_name')) {
      context.handle(
        _posterNameMeta,
        posterName.isAcceptableOrUnknown(data['poster_name']!, _posterNameMeta),
      );
    } else if (isInserting) {
      context.missing(_posterNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBlog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBlog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      posterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      topicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      posterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_name'],
      )!,
    );
  }

  @override
  $CachedBlogsTable createAlias(String alias) {
    return $CachedBlogsTable(attachedDatabase, alias);
  }
}

class CachedBlog extends DataClass implements Insertable<CachedBlog> {
  /// The unique identifier for the blog.
  /// This is the primary key for the table.
  final String id;

  /// The identifier of the user who posted the blog.
  final String posterId;

  /// The title of the blog.
  final String title;

  /// The content of the blog.
  final String content;

  /// The URL of the image associated with the blog.
  final String imageUrl;

  /// The JSON string representing the topics of the blog.
  final String topicsJson;

  /// The date and time when the blog was created.
  final DateTime createdAt;

  /// The date and time when the blog was last updated.
  final DateTime updatedAt;

  /// The name of the user who posted the blog.
  final String posterName;
  const CachedBlog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topicsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.posterName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poster_id'] = Variable<String>(posterId);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['image_url'] = Variable<String>(imageUrl);
    map['topics_json'] = Variable<String>(topicsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['poster_name'] = Variable<String>(posterName);
    return map;
  }

  CachedBlogsCompanion toCompanion(bool nullToAbsent) {
    return CachedBlogsCompanion(
      id: Value(id),
      posterId: Value(posterId),
      title: Value(title),
      content: Value(content),
      imageUrl: Value(imageUrl),
      topicsJson: Value(topicsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      posterName: Value(posterName),
    );
  }

  factory CachedBlog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBlog(
      id: serializer.fromJson<String>(json['id']),
      posterId: serializer.fromJson<String>(json['posterId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      topicsJson: serializer.fromJson<String>(json['topicsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      posterName: serializer.fromJson<String>(json['posterName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'posterId': serializer.toJson<String>(posterId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'topicsJson': serializer.toJson<String>(topicsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'posterName': serializer.toJson<String>(posterName),
    };
  }

  CachedBlog copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageUrl,
    String? topicsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? posterName,
  }) => CachedBlog(
    id: id ?? this.id,
    posterId: posterId ?? this.posterId,
    title: title ?? this.title,
    content: content ?? this.content,
    imageUrl: imageUrl ?? this.imageUrl,
    topicsJson: topicsJson ?? this.topicsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    posterName: posterName ?? this.posterName,
  );
  CachedBlog copyWithCompanion(CachedBlogsCompanion data) {
    return CachedBlog(
      id: data.id.present ? data.id.value : this.id,
      posterId: data.posterId.present ? data.posterId.value : this.posterId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      topicsJson: data.topicsJson.present
          ? data.topicsJson.value
          : this.topicsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      posterName: data.posterName.present
          ? data.posterName.value
          : this.posterName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBlog(')
          ..write('id: $id, ')
          ..write('posterId: $posterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('posterName: $posterName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    posterId,
    title,
    content,
    imageUrl,
    topicsJson,
    createdAt,
    updatedAt,
    posterName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBlog &&
          other.id == this.id &&
          other.posterId == this.posterId &&
          other.title == this.title &&
          other.content == this.content &&
          other.imageUrl == this.imageUrl &&
          other.topicsJson == this.topicsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.posterName == this.posterName);
}

class CachedBlogsCompanion extends UpdateCompanion<CachedBlog> {
  final Value<String> id;
  final Value<String> posterId;
  final Value<String> title;
  final Value<String> content;
  final Value<String> imageUrl;
  final Value<String> topicsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> posterName;
  final Value<int> rowid;
  const CachedBlogsCompanion({
    this.id = const Value.absent(),
    this.posterId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.posterName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBlogsCompanion.insert({
    required String id,
    required String posterId,
    required String title,
    required String content,
    required String imageUrl,
    required String topicsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String posterName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       posterId = Value(posterId),
       title = Value(title),
       content = Value(content),
       imageUrl = Value(imageUrl),
       topicsJson = Value(topicsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       posterName = Value(posterName);
  static Insertable<CachedBlog> custom({
    Expression<String>? id,
    Expression<String>? posterId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? imageUrl,
    Expression<String>? topicsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? posterName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (posterId != null) 'poster_id': posterId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      if (topicsJson != null) 'topics_json': topicsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (posterName != null) 'poster_name': posterName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBlogsCompanion copyWith({
    Value<String>? id,
    Value<String>? posterId,
    Value<String>? title,
    Value<String>? content,
    Value<String>? imageUrl,
    Value<String>? topicsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? posterName,
    Value<int>? rowid,
  }) {
    return CachedBlogsCompanion(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topicsJson: topicsJson ?? this.topicsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      posterName: posterName ?? this.posterName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (posterId.present) {
      map['poster_id'] = Variable<String>(posterId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (topicsJson.present) {
      map['topics_json'] = Variable<String>(topicsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (posterName.present) {
      map['poster_name'] = Variable<String>(posterName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBlogsCompanion(')
          ..write('id: $id, ')
          ..write('posterId: $posterId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('posterName: $posterName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Stable setting identifier.
  final String key;

  /// Persisted setting value.
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrentAuthUsersTable extends CurrentAuthUsers
    with TableInfo<$CurrentAuthUsersTable, CurrentAuthUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrentAuthUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonKeyMeta = const VerificationMeta(
    'singletonKey',
  );
  @override
  late final GeneratedColumn<int> singletonKey = GeneratedColumn<int>(
    'singleton_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [singletonKey, id, email, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'current_auth_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrentAuthUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_key')) {
      context.handle(
        _singletonKeyMeta,
        singletonKey.isAcceptableOrUnknown(
          data['singleton_key']!,
          _singletonKeyMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonKey};
  @override
  CurrentAuthUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrentAuthUser(
      singletonKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_key'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CurrentAuthUsersTable createAlias(String alias) {
    return $CurrentAuthUsersTable(attachedDatabase, alias);
  }
}

class CurrentAuthUser extends DataClass implements Insertable<CurrentAuthUser> {
  /// Singleton row identifier used to keep at most one current user row.
  final int singletonKey;

  /// Current authenticated user identifier.
  final String id;

  /// Current authenticated user email address.
  final String email;

  /// Current authenticated user display name.
  final String name;
  const CurrentAuthUser({
    required this.singletonKey,
    required this.id,
    required this.email,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_key'] = Variable<int>(singletonKey);
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    return map;
  }

  CurrentAuthUsersCompanion toCompanion(bool nullToAbsent) {
    return CurrentAuthUsersCompanion(
      singletonKey: Value(singletonKey),
      id: Value(id),
      email: Value(email),
      name: Value(name),
    );
  }

  factory CurrentAuthUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrentAuthUser(
      singletonKey: serializer.fromJson<int>(json['singletonKey']),
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonKey': serializer.toJson<int>(singletonKey),
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
    };
  }

  CurrentAuthUser copyWith({
    int? singletonKey,
    String? id,
    String? email,
    String? name,
  }) => CurrentAuthUser(
    singletonKey: singletonKey ?? this.singletonKey,
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
  );
  CurrentAuthUser copyWithCompanion(CurrentAuthUsersCompanion data) {
    return CurrentAuthUser(
      singletonKey: data.singletonKey.present
          ? data.singletonKey.value
          : this.singletonKey,
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrentAuthUser(')
          ..write('singletonKey: $singletonKey, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonKey, id, email, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrentAuthUser &&
          other.singletonKey == this.singletonKey &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name);
}

class CurrentAuthUsersCompanion extends UpdateCompanion<CurrentAuthUser> {
  final Value<int> singletonKey;
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  const CurrentAuthUsersCompanion({
    this.singletonKey = const Value.absent(),
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
  });
  CurrentAuthUsersCompanion.insert({
    this.singletonKey = const Value.absent(),
    required String id,
    required String email,
    required String name,
  }) : id = Value(id),
       email = Value(email),
       name = Value(name);
  static Insertable<CurrentAuthUser> custom({
    Expression<int>? singletonKey,
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (singletonKey != null) 'singleton_key': singletonKey,
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
    });
  }

  CurrentAuthUsersCompanion copyWith({
    Value<int>? singletonKey,
    Value<String>? id,
    Value<String>? email,
    Value<String>? name,
  }) {
    return CurrentAuthUsersCompanion(
      singletonKey: singletonKey ?? this.singletonKey,
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonKey.present) {
      map['singleton_key'] = Variable<int>(singletonKey.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrentAuthUsersCompanion(')
          ..write('singletonKey: $singletonKey, ')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedBlogsTable cachedBlogs = $CachedBlogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CurrentAuthUsersTable currentAuthUsers = $CurrentAuthUsersTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedBlogs,
    appSettings,
    currentAuthUsers,
  ];
}

typedef $$CachedBlogsTableCreateCompanionBuilder =
    CachedBlogsCompanion Function({
      required String id,
      required String posterId,
      required String title,
      required String content,
      required String imageUrl,
      required String topicsJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String posterName,
      Value<int> rowid,
    });
typedef $$CachedBlogsTableUpdateCompanionBuilder =
    CachedBlogsCompanion Function({
      Value<String> id,
      Value<String> posterId,
      Value<String> title,
      Value<String> content,
      Value<String> imageUrl,
      Value<String> topicsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> posterName,
      Value<int> rowid,
    });

class $$CachedBlogsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBlogsTable> {
  $$CachedBlogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBlogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBlogsTable> {
  $$CachedBlogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterId => $composableBuilder(
    column: $table.posterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBlogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBlogsTable> {
  $$CachedBlogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get posterId =>
      $composableBuilder(column: $table.posterId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get posterName => $composableBuilder(
    column: $table.posterName,
    builder: (column) => column,
  );
}

class $$CachedBlogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedBlogsTable,
          CachedBlog,
          $$CachedBlogsTableFilterComposer,
          $$CachedBlogsTableOrderingComposer,
          $$CachedBlogsTableAnnotationComposer,
          $$CachedBlogsTableCreateCompanionBuilder,
          $$CachedBlogsTableUpdateCompanionBuilder,
          (
            CachedBlog,
            BaseReferences<_$AppDatabase, $CachedBlogsTable, CachedBlog>,
          ),
          CachedBlog,
          PrefetchHooks Function()
        > {
  $$CachedBlogsTableTableManager(_$AppDatabase db, $CachedBlogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBlogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBlogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBlogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> posterId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> topicsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> posterName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBlogsCompanion(
                id: id,
                posterId: posterId,
                title: title,
                content: content,
                imageUrl: imageUrl,
                topicsJson: topicsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                posterName: posterName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String posterId,
                required String title,
                required String content,
                required String imageUrl,
                required String topicsJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String posterName,
                Value<int> rowid = const Value.absent(),
              }) => CachedBlogsCompanion.insert(
                id: id,
                posterId: posterId,
                title: title,
                content: content,
                imageUrl: imageUrl,
                topicsJson: topicsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                posterName: posterName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBlogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedBlogsTable,
      CachedBlog,
      $$CachedBlogsTableFilterComposer,
      $$CachedBlogsTableOrderingComposer,
      $$CachedBlogsTableAnnotationComposer,
      $$CachedBlogsTableCreateCompanionBuilder,
      $$CachedBlogsTableUpdateCompanionBuilder,
      (
        CachedBlog,
        BaseReferences<_$AppDatabase, $CachedBlogsTable, CachedBlog>,
      ),
      CachedBlog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CurrentAuthUsersTableCreateCompanionBuilder =
    CurrentAuthUsersCompanion Function({
      Value<int> singletonKey,
      required String id,
      required String email,
      required String name,
    });
typedef $$CurrentAuthUsersTableUpdateCompanionBuilder =
    CurrentAuthUsersCompanion Function({
      Value<int> singletonKey,
      Value<String> id,
      Value<String> email,
      Value<String> name,
    });

class $$CurrentAuthUsersTableFilterComposer
    extends Composer<_$AppDatabase, $CurrentAuthUsersTable> {
  $$CurrentAuthUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrentAuthUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrentAuthUsersTable> {
  $$CurrentAuthUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrentAuthUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrentAuthUsersTable> {
  $$CurrentAuthUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonKey => $composableBuilder(
    column: $table.singletonKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CurrentAuthUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrentAuthUsersTable,
          CurrentAuthUser,
          $$CurrentAuthUsersTableFilterComposer,
          $$CurrentAuthUsersTableOrderingComposer,
          $$CurrentAuthUsersTableAnnotationComposer,
          $$CurrentAuthUsersTableCreateCompanionBuilder,
          $$CurrentAuthUsersTableUpdateCompanionBuilder,
          (
            CurrentAuthUser,
            BaseReferences<
              _$AppDatabase,
              $CurrentAuthUsersTable,
              CurrentAuthUser
            >,
          ),
          CurrentAuthUser,
          PrefetchHooks Function()
        > {
  $$CurrentAuthUsersTableTableManager(
    _$AppDatabase db,
    $CurrentAuthUsersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrentAuthUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrentAuthUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrentAuthUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => CurrentAuthUsersCompanion(
                singletonKey: singletonKey,
                id: id,
                email: email,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonKey = const Value.absent(),
                required String id,
                required String email,
                required String name,
              }) => CurrentAuthUsersCompanion.insert(
                singletonKey: singletonKey,
                id: id,
                email: email,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrentAuthUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrentAuthUsersTable,
      CurrentAuthUser,
      $$CurrentAuthUsersTableFilterComposer,
      $$CurrentAuthUsersTableOrderingComposer,
      $$CurrentAuthUsersTableAnnotationComposer,
      $$CurrentAuthUsersTableCreateCompanionBuilder,
      $$CurrentAuthUsersTableUpdateCompanionBuilder,
      (
        CurrentAuthUser,
        BaseReferences<_$AppDatabase, $CurrentAuthUsersTable, CurrentAuthUser>,
      ),
      CurrentAuthUser,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedBlogsTableTableManager get cachedBlogs =>
      $$CachedBlogsTableTableManager(_db, _db.cachedBlogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CurrentAuthUsersTableTableManager get currentAuthUsers =>
      $$CurrentAuthUsersTableTableManager(_db, _db.currentAuthUsers);
}
