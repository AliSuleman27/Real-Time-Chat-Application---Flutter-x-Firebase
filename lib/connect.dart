import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pchat_app/main.dart';
import 'package:pchat_app/pages/disconnected.dart';

class ConnectionGate extends StatelessWidget {
  ConnectionGate({super.key});
  @override
  Widget build(BuildContext context) {
    StreamController<bool> _isConnectedController = StreamController<bool>();
    final listener = InternetConnection().onStatusChange.listen((status) {
      _isConnectedController.add(status == InternetStatus.connected);
      log(status.name);
    });

    return StreamBuilder(
        stream: _isConnectedController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final connectivityStatus = snapshot.data!;
            return connectivityStatus
                ? MyApp()
                : const DisconnectedPage(
                    text: "Please Connect to the Internet");
          } else {
            return const DisconnectedPage(text: "Waiting for the connection!");
          }
        });
  }
}
