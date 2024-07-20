import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/models/user_profile.dart';
import 'package:pchat_app/pages/chat_page.dart';
import 'package:pchat_app/services/alert_service.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/database_service.dart';
import 'package:pchat_app/services/navigation_service.dart';
import 'package:pchat_app/widgets/chat_tile.dart';
import 'package:pchat_app/widgets/customFormField.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Global Services
  final _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
        ),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                if (result) {
                  _alertService.showToast(message: "Logged Out Successfully");
                  _navigationService.pushReplacementNamed("/login");
                } else {}
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Search',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase();
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(child: _chatList()),
          ],
        ),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getUsersProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            const Center(
              child: Text("Unable to Load Data"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final List<UserProfile> users;
            if (searchQuery != '') {
              users = snapshot.data!.docs
                  .map((doc) {
                    return doc.data();
                  })
                  .where((user) =>
                      user.name!.toLowerCase().startsWith(searchQuery))
                  .toList();
            } else {
              users = snapshot.data!.docs.map((doc) {
                return doc.data();
              }).toList();
            }
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ChatTile(
                        userProfile: user,
                        onTap: () async {
                          bool chatExists = await _databaseService.chatExists(
                              _authService.user!.uid, user.uid!);
                          log(chatExists.toString());
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                                _authService.user!.uid, user.uid!);
                          }
                          _navigationService
                              .push(MaterialPageRoute(builder: (context) {
                            return ChatPage(userProfile: user);
                          }));
                        }),
                  );
                });
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
