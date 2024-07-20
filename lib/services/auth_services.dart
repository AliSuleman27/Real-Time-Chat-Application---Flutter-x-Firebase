import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChangesListener);
  }

  Future<bool> login(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credentials.user != null) {
        log("USER FOUND");
        _user = credentials.user;
        return true;
      }
    } catch (e) {
      log(e.toString());
    }
    log("USER NOT FOUND");
    return false;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        return true;
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  void authStateChangesListener(User? user) {
    _user = user;
  }
}
