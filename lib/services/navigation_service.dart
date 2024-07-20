import 'package:flutter/material.dart';
import 'package:pchat_app/pages/home_page.dart';
import 'package:pchat_app/pages/login_page.dart';
import 'package:pchat_app/pages/register_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/home": (context) => HomePage(),
    "/register": (context) => RegisterPage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  Map<String, Widget Function(BuildContext)> get routes => _routes;

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }

  void push(MaterialPageRoute route) {
    navigatorKey?.currentState?.push(route);
  }
}
