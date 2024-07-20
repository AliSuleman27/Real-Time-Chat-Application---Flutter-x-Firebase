import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/models/chat.dart';
import 'package:pchat_app/models/message.dart';
import 'package:pchat_app/models/user_profile.dart';
import 'package:pchat_app/services/auth_services.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  CollectionReference? _userCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(fromFirestore: (snapshot, _) {
      return UserProfile.fromJson(snapshot.data()!);
    }, toFirestore: (userProfile, _) {
      return userProfile.toJson();
    });

    _chatsCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(fromFirestore: (snapshpts, _) {
      return Chat.fromJson(snapshpts.data()!);
    }, toFirestore: (chatInstance, _) {
      return chatInstance.toJson();
    });
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _userCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUsersProfiles() {
    return _userCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  String generateChatId(String uid0, String uid1) {
    List uids = [uid0, uid1];
    uids.sort();
    String chatId = uids.fold("", (id1, id2) => "$id1$id2");
    return chatId;
  }

  Future<bool> chatExists(String uid0, String uid1) async {
    final chatId = generateChatId(uid0, uid1);
    final result = await _chatsCollection?.doc(chatId).get();
    return result != null ? result.exists : false;
  }

  Future<void> createNewChat(String uid0, String uid1) async {
    final chatId = generateChatId(uid0, uid1);
    final docRef = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid0, uid1], messages: []);
    docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid0, String uid1, Message message) async {
    String chatId = generateChatId(uid0, uid1);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update({
      "messages": FieldValue.arrayUnion([
        message.toJson(),
      ])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid0, String uid1) {
    String chatId = generateChatId(uid0, uid1);
    final docRef = _chatsCollection!.doc(chatId);
    return docRef.snapshots() as Stream<DocumentSnapshot<Chat>>;
  }
}
