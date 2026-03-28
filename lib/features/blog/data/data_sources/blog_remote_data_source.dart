import 'dart:async';
import 'dart:io';

import 'package:social_app/core/constants/supabase_schema/buckets.dart';
import 'package:social_app/core/constants/supabase_schema/fields/'
    'blog_fields.dart';
import 'package:social_app/core/constants/supabase_schema/fields/'
    'profile_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A blog remote data source.
abstract interface class BlogRemoteDataSource {
  /// The post blog.
  Future<BlogModel> postBlog(BlogModel blog);

  /// The upload blog image.
  Future<String> uploadBlogImage({required File image, required String blogId});

  /// The get blogs page.
  Future<List<BlogModel>> getBlogsPage(int page);

  // Returns the total number of blogs in the database
  /// The get blogs count.
  Future<int> getBlogsCount();

  /// The watch blog changes.
  Stream<BlogChange> watchBlogChanges();
}

/// A blog remote data source impl.
class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  /// Creates a [BlogRemoteDataSourceImpl].
  BlogRemoteDataSourceImpl({required this.supabaseClient});

  /// The supabase client.
  SupabaseClient supabaseClient;

  @override
  Future<BlogModel> postBlog(BlogModel blog) async {
    return guardRemoteDataSourceCall(() async {
      final blogData = await supabaseClient
          .from(Tables.blogs)
          .insert(blog.toJson())
          .select();

      return BlogModel.fromJson(blogData.first);
    });
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required String blogId,
  }) async {
    return guardRemoteDataSourceCall(() async {
      await supabaseClient.storage
          .from(Buckets.blogImages)
          .upload(blogId, image);
      return supabaseClient.storage
          .from(Buckets.blogImages)
          .getPublicUrl(blogId);
    });
  }

  @override
  Future<List<BlogModel>> getBlogsPage(int pageNumber) async {
    return guardRemoteDataSourceCall(() async {
      const pageSize = 20;
      final from = (pageNumber - 1) * pageSize;
      final to = from + pageSize - 1;

      final rawBlogs = await supabaseClient
          .from(Tables.blogs)
          .select('*, ${Tables.profiles} (${ProfileFields.name})')
          .range(from, to)
          .order(BlogFields.updatedAt, ascending: false);

      return rawBlogs.map(
        (rawBlog) {
          final profile = rawBlog[Tables.profiles] as Map<String, dynamic>?;
          final posterName = profile?[ProfileFields.name] as String?;
          return BlogModel.fromJson(rawBlog).copyWith(
            posterName: posterName,
          );
        },
      ).toList();
    });
  }

  @override
  Future<int> getBlogsCount() async {
    return guardRemoteDataSourceCall(() async {
      return await supabaseClient.from(Tables.blogs).count();
    });
  }

  /// Watches real-time changes on the `blogs` table and emits domain-level
  /// [BlogChange] events (insert / update / delete).
  ///
  /// ### Why a `StreamController` is used
  /// Supabase Realtime exposes a **callback-based API**, not a Dart `Stream`.
  /// This method acts as an **adapter** that converts imperative callbacks
  /// (`onPostgresChanges`) into a composable Dart `Stream`.
  ///
  /// The `StreamController` is responsible for:
  /// - manually emitting events (`add`)
  /// - emitting errors (`addError`)
  /// - managing the subscription lifecycle
  ///
  /// ### Emitted events
  /// Each Postgres change is translated into a domain-specific event:
  /// - INSERT  → [BlogInserted]
  /// - UPDATE  → [BlogUpdated]
  /// - DELETE  → [BlogDeleted]
  ///
  /// This keeps the domain and presentation layers independent from
  /// Supabase-specific payloads.
  ///
  /// ### Stream lifecycle
  /// - The Realtime channel is created and subscribed **when the first listener
  ///   subscribes** to the stream (`onListen`).
  /// - The channel is unsubscribed **when the last listener cancels** the
  ///   subscription (`onCancel`).
  ///
  /// This ensures:
  /// - no unnecessary open connections
  /// - proper cleanup when the stream is no longer needed
  ///
  /// ### Error handling
  /// - Errors thrown while parsing or mapping payloads are added to the stream
  ///   via `addError`.
  /// - The stream itself is **not closed** on error.
  /// - Higher layers (repository) are responsible for translating errors into
  ///   domain failures.
  ///
  /// ### Architectural note
  /// This method belongs to the **data layer** and performs infrastructure
  /// adaptation only. It must not:
  /// - emit UI states
  /// - apply business rules
  /// - translate errors into domain failures
  ///
  /// Those responsibilities are intentionally handled in upper layers.
  @override
  Stream<BlogChange> watchBlogChanges() {
    late final StreamController<BlogChange> controller;
    late final RealtimeChannel channel;

    controller = StreamController<BlogChange>(
      onListen: () {
        channel =
            supabaseClient.realtime.channel(
                '${SchemaTypes.public}:${Tables.blogs}',
              )
              ..onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: SchemaTypes.public,
                table: Tables.blogs,
                callback: (payload) {
                  try {
                    switch (payload.eventType) {
                      case PostgresChangeEvent.insert:
                        controller.add(
                          BlogInserted(
                            BlogModel.fromJson(payload.newRecord).toEntity(),
                          ),
                        );

                      case PostgresChangeEvent.update:
                        controller.add(
                          BlogUpdated(
                            BlogModel.fromJson(payload.newRecord).toEntity(),
                          ),
                        );

                      case PostgresChangeEvent.delete:
                        final deletedBlogId =
                            payload.oldRecord[BlogFields.id] as String;
                        controller.add(BlogDeleted(deletedBlogId));

                      case PostgresChangeEvent.all:
                        // Required for exhaustive handling
                        // but never emitted here.
                        break;
                    }
                  } on Exception catch (e, stack) {
                    controller.addError(
                      ServerException(message: e.toString()),
                      stack,
                    );
                  }
                },
              )
              ..subscribe();
      },
      onCancel: () async {
        await controller.close();
        await channel.unsubscribe();
      },
    );

    return controller.stream;
  }
}
