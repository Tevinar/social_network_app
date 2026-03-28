// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:social_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_app/features/chat/data/models/chat_model.dart';

abstract interface class ChatRemoteDataSource {
  /// Creates a chat with the given members and an initial message.
  /// Returns the created chat with its first message.
  Future<ChatModel> createChat(
    List<UserModel> members,
    String firstMessageContent,
  );

  /// Fetches a paginated list of chats ordered by last activity.
  Future<List<ChatModel>> getChatsPage(int pageNumber);

  /// Returns the total number of chats in the database.
  Future<int> getChatsCount();

  /// Emits chat insert/update/delete events in realtime.
  Stream<ChatChange> watchChatChanges();

  /// Fetches a single chat with members and last message.
  Future<ChatModel> getChatById(String chatId);

  Future<ChatModel?> getChatByMembers(List<UserModel> members);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

  /// Shared select clause used to fetch a fully hydrated chat.
  ///
  /// Includes:
  /// - chat id
  /// - members with profiles
  /// - last message via foreign key
  final String _chatSelect =
      '''
        ${ChatFields.id},
        ${Tables.chatMembers} (
          ${Tables.profiles} (*)
        ),
        ${Tables.chatMessages}!${ChatForeignKeys.lastMessageFkey} (*)
      ''';

  @override
  Future<ChatModel> createChat(
    List<UserModel> members,
    String firstMessageContent,
  ) async {
    return guardRemoteDataSourceCall(() async {
      final Map<String, dynamic> firstMessageData = await supabaseClient.rpc(
        'create_chat_with_members',
        params: {
          'member_ids': members.map((e) => e.id).toList(),
          'first_message_content': firstMessageContent,
        },
      );

      final ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(
        firstMessageData,
      );

      return ChatModel(
        id: chatMessageModel.id,
        lastMessage: chatMessageModel,
        members: members,
      );
    });
  }

  @override
  Future<List<ChatModel>> getChatsPage(int pageNumber) async {
    return guardRemoteDataSourceCall(() async {
      const int pageSize = 20;
      final int from = (pageNumber - 1) * pageSize;
      final int to = from + pageSize - 1;

      final List<Map<String, dynamic>> rawChats = await supabaseClient
          .from(Tables.chats)
          .select(_chatSelect)
          .range(from, to)
          .order(ChatFields.lastMessageAt, ascending: false);
      return rawChats.map(ChatModel.fromJson).toList();
    });
  }

  @override
  Future<int> getChatsCount() async {
    return guardRemoteDataSourceCall(() async {
      return await supabaseClient.from(Tables.chats).count();
    });
  }

  @override
  Stream<ChatChange> watchChatChanges() {
    late final StreamController<ChatChange> controller;
    late final RealtimeChannel channel;

    controller = StreamController<ChatChange>(
      onListen: () {
        channel = supabaseClient.realtime.channel(
          '${SchemaTypes.public}:${Tables.chats}',
        );

        /// No need to filter by user here, as the RLS policies will ensure that
        /// only relevant changes are sent to the client.
        channel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: SchemaTypes.public,
          table: Tables.chats,
          callback: (payload) async {
            try {
              switch (payload.eventType) {
                case PostgresChangeEvent.insert:
                  final chatId = payload.newRecord[ChatFields.id] as String;
                  final ChatModel chat = await getChatById(chatId);
                  controller.add(ChatInserted(chat.toEntity()));
                  break;

                case PostgresChangeEvent.update:
                  final chatId = payload.newRecord[ChatFields.id] as String;
                  final ChatModel chat = await getChatById(chatId);
                  controller.add(ChatUpdated(chat.toEntity()));
                  break;

                case PostgresChangeEvent.delete:
                  final String deletedChatId = payload.oldRecord[ChatFields.id] as String;
                  controller.add(ChatDeleted(deletedChatId));
                  break;

                case PostgresChangeEvent.all:
                  // Not emitted as a payload event, but required for exhaustiveness
                  break;
              }
            } catch (e, stack) {
              controller.addError(
                ServerException(message: e.toString()),
                stack,
              );
            }
          },
        );

        channel.subscribe();
      },
      onCancel: () async {
        await controller.close();
        await channel.unsubscribe();
      },
    );

    return controller.stream;
  }

  @override
  Future<ChatModel> getChatById(String chatId) async {
    return guardRemoteDataSourceCall(() async {
      final PostgrestMap result = await supabaseClient
          .from(Tables.chats)
          .select(_chatSelect)
          .eq(ChatFields.id, chatId)
          .single();
      return ChatModel.fromJson(result);
    });
  }

  @override
  Future<ChatModel?> getChatByMembers(List<UserModel> members) {
    return guardRemoteDataSourceCall(() async {
      final Map<String, dynamic>? result = await supabaseClient.rpc<Map<String, dynamic>?>(
        'get_chat_by_members',
        params: {'member_ids': members.map((e) => e.id).toList()},
      );

      if (result == null) return null;
      return ChatModel.fromJson(result);
    });
  }
}
