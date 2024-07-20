import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/models/chat.dart';
import 'package:pchat_app/models/message.dart';
import 'package:pchat_app/models/user_profile.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/database_service.dart';
import 'package:pchat_app/services/media_service.dart';
import 'package:pchat_app/services/storage_services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.userProfile});
  final UserProfile userProfile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.userProfile.uid!,
        firstName: widget.userProfile.name,
        profileImage: widget.userProfile.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile.name!),
      ),
      body: _buildUI(),
    );
  }

  Future<void> _sendMessage(ChatMessage message) async {
    if (message.medias?.isNotEmpty ?? false) {
      if (message.medias!.first.type == MediaType.image) {
        Message newMessage = Message(
            senderID: currentUser!.id,
            content: message.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(message.createdAt));
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, newMessage);
      }
    } else {
      Message newMessage = Message(
          senderID: currentUser!.id,
          content: message.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(message.createdAt));
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, newMessage);
    }
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];

          if (chat != null && chat.messages != null) {
            messages = generateChat(chat.messages!);
          }

          return DashChat(
              messageOptions: const MessageOptions(
                showOtherUsersAvatar: true,
                showTime: true,
              ),
              inputOptions: InputOptions(
                  alwaysShowSend: true, trailing: [_mediaMessageButton()]),
              currentUser: currentUser!,
              onSend: (message) {
                _sendMessage(message);
              },
              messages: messages);
        });
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.getFileFromGallery();
          if (file != null) {
            String? downloadUrl = await _storageService.uploadChatMedia(
                file: file,
                chatId: _databaseService.generateChatId(
                    currentUser!.id, otherUser!.id));
            if (downloadUrl != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadUrl, fileName: "", type: MediaType.image)
                  ]);
              _sendMessage(chatMessage);
            }
          } else {}
        },
        icon: const Icon(Icons.image));
  }

  List<ChatMessage> generateChat(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ],
            createdAt: m.sentAt!.toDate());
      }

      return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate());
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }
}
