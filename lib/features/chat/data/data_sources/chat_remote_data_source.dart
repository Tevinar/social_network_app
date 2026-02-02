// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/core/errors/exceptions_mapper.dart';
import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/chat/data/models/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bloc_app/features/chat/data/models/chat_model.dart';

abstract interface class ChatRemoteDataSource {
  Future<ChatModel> createChat(
    List<UserModel> members,
    String firstMessageContent,
  );
  Future<List<ChatModel>> getChatsPage(int pageNumber);
  Future<int> getChatsCount();
  // Stream<ChatChange> watchChatChanges();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl({required this.supabaseClient});

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

      ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(
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
          .select('''
          ${ChatFields.id},
          ${Tables.chatMembers} (
            ${Tables.profiles} (*)
          ),
          ${Tables.chatMessages}!{${ChatForeignKeys.lastMessageFkey}} (
            *,
            ${Tables.profiles} (*)
          )
          ''')
          .range(from, to)
          .order(ChatFields.lastMessageAt, ascending: false);
      print(rawChats);
      return rawChats.map((rawChat) => ChatModel.fromJson(rawChat)).toList();
    });
  }

  @override
  Future<int> getChatsCount() async {
    return guardRemoteDataSourceCall(() async {
      return await supabaseClient.from(Tables.chats).count();
    });
  }

  // @override
  // Stream<ChatChange> watchChatChanges() {
  //   late final StreamController<ChatChange> controller;
  //   late final RealtimeChannel channel;

  //   controller = StreamController<ChatChange>(
  //     onListen: () {
  //       channel = supabaseClient.realtime.channel(
  //         '${SchemaTypes.public}:${Tables.blogs}',
  //       );

  //       channel.onPostgresChanges(
  //         event: PostgresChangeEvent.all,
  //         schema: SchemaTypes.public,
  //         table: Tables.blogs,
  //         callback: (payload) {
  //           try {
  //             switch (payload.eventType) {
  //               case PostgresChangeEvent.insert:
  //                 controller.add(
  //                   BlogInserted(
  //                     BlogModel.fromJson(payload.newRecord).toEntity(),
  //                   ),
  //                 );
  //                 break;

  //               case PostgresChangeEvent.update:
  //                 controller.add(
  //                   BlogUpdated(
  //                     BlogModel.fromJson(payload.newRecord).toEntity(),
  //                   ),
  //                 );
  //                 break;

  //               case PostgresChangeEvent.delete:
  //                 controller.add(BlogDeleted(payload.oldRecord[BlogFields.id]));
  //                 break;

  //               case PostgresChangeEvent.all:
  //                 // Not emitted as a payload event, but required for exhaustiveness
  //                 break;
  //             }
  //           } catch (e, stack) {
  //             controller.addError(
  //               ServerException(message: e.toString()),
  //               stack,
  //             );
  //           }
  //         },
  //       );

  //       channel.subscribe();
  //     },
  //     onCancel: () async {
  //       await channel.unsubscribe();
  //     },
  //   );

  //   return controller.stream;
  // }
}
