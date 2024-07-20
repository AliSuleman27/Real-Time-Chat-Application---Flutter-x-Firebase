import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:pchat_app/connect.dart';
import 'package:pchat_app/pages/disconnected.dart';
import 'package:pchat_app/services/auth_services.dart';
import 'package:pchat_app/services/navigation_service.dart';
import 'package:pchat_app/utils.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.allowReassignment = true;
  runApp(ConnectionGate());
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  NavigationService? _navigationService;
  AuthService? _authService;
  bool setupInitialised = false;

  Future<bool> setupServices() async {
    if (setupInitialised) return true;
    try {
      await setupFirebase();
      log("Firebase Successfully Connected");
      registerServices();
      log("Services Registered Successfully");
      _navigationService = _getIt.get<NavigationService>();
      _authService = _getIt.get<AuthService>();
      setupInitialised = true;
      return true;
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: setupServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            !snapshot.data!) {
          return const DisconnectedPage(
              text: "Getting Things Ready for You!!!");
        }

        return MaterialApp(
          navigatorKey: _navigationService!.navigatorKey,
          routes: _navigationService!.routes,
          initialRoute: _authService!.user != null ? "/home" : "/login",
          debugShowCheckedModeBanner: false,
          title: 'Private Chat Application',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
        );
      },
    );
  }
}
