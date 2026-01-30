import 'dart:io';

import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/constants/supabase_schema/buckets.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/blog_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:bloc_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> postBlog(BlogModel blog);
  Future<String> uploadBlogImage({required File image, required String blogId});
  Future<List<BlogModel>> getBlogsPage(int page);

  // Returns the total number of blogs in the database
  Future<int> getBlogsCount();
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
}
