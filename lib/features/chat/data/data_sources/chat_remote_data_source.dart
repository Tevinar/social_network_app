// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bloc_app/features/chat/data/models/chat_model.dart';

abstract interface class ChatRemoteDataSource {
  Future<ChatModel> createChat(List<String> memberIds);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ChatModel> createChat(List<String> memberIds) async {
    try {
      final List<Map<String, dynamic>> chatData = await supabaseClient.rpc(
        'create_chat_with_members',
        params: {'member_ids': memberIds},
      );

      return ChatModel.fromJson(chatData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
