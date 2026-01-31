import 'dart:io';

import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/constants/supabase_schema/buckets.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/blog_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:bloc_app/features/blog/data/models/blog_model.dart';
import 'package:bloc_app/features/blog/domain/entities/blog_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> postBlog(BlogModel blog);
  Future<String> uploadBlogImage({required File image, required String blogId});
  Future<List<BlogModel>> getBlogsPage(int page);

  // Returns the total number of blogs in the database
  Future<int> getBlogsCount();
  Stream<BlogChange> watchBlogChanges();
}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  SupabaseClient supabaseClient;

  BlogRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BlogModel> postBlog(BlogModel blog) async {
    try {
      final List<Map<String, dynamic>> blogData = await supabaseClient
          .from(Tables.blogs)
          .insert(blog.toJson())
          .select();

      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required String blogId,
  }) async {
    try {
      await supabaseClient.storage
          .from(Buckets.blogImages)
          .upload(blogId, image);
      return supabaseClient.storage
          .from(Buckets.blogImages)
          .getPublicUrl(blogId);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getBlogsPage(int pageNumber) async {
    try {
      if (pageNumber < 1) {
        throw ArgumentError(ErrorMessages.pageNumberInvalid);
      }

      const int pageSize = 20;
      final int from = (pageNumber - 1) * pageSize;
      final int to = from + pageSize - 1;

      final List<Map<String, dynamic>> rawBlogs = await supabaseClient
          .from(Tables.blogs)
          .select('*, ${Tables.profiles} (${ProfileFields.name})')
          .range(from, to)
          .order(BlogFields.updatedAt, ascending: false);

      return rawBlogs
          .map(
            (rawBlog) => BlogModel.fromJson(rawBlog).copyWith(
              posterName: rawBlog[Tables.profiles][ProfileFields.name],
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getBlogsCount() async {
    try {
      return await supabaseClient.from(Tables.blogs).count();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Supabase streams emit full snapshots, so we diff locally to derive events.
  @override
  Stream<BlogChange> watchBlogChanges() {
    final Map<String, BlogModel> previousBlogs = {};

    return supabaseClient
        .from(Tables.blogs)
        .stream(primaryKey: [BlogFields.id])
        .order(BlogFields.updatedAt)
        /// puting order is crucial for detecting updates of existing rows. Because Supabase will emit snapshots only if at least
        /// one of these conditions change :
        /// - row identity (primary key)
        /// - row ordering
        /// - row presence in the result set
        .asyncExpand<BlogChange>((List<Map<String, dynamic>> rows) {
          try {
            final List<BlogChange> changes = [];

            final Map<String, BlogModel> currentBlogs = {
              for (final Map<String, dynamic> row in rows)
                row[BlogFields.id]: BlogModel.fromJson(row),
            };

            // INSERTS & UPDATES
            for (final entry in currentBlogs.entries) {
              final id = entry.key;
              final blog = entry.value;
              final previous = previousBlogs[id];

              if (previous == null) {
                changes.add(BlogInserted(blog));
              } else if (previous.updatedAt != blog.updatedAt) {
                changes.add(BlogUpdated(blog));
              }
            }

            // DELETES
            for (final id in previousBlogs.keys) {
              if (!currentBlogs.containsKey(id)) {
                changes.add(BlogDeleted(id));
              }
            }

            previousBlogs
              ..clear()
              ..addAll(currentBlogs);

            return Stream<BlogChange>.fromIterable(changes);
          } catch (e, stack) {
            // Forward error, but keep stream typed
            return Stream<BlogChange>.error(
              ServerException(e.toString()),
              stack,
            );
          }
        })
        .handleError((error, stack) {
          throw ServerException(error.toString());
        });
  }
}
