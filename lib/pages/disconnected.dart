import 'package:flutter/material.dart';

class DisconnectedPage extends StatelessWidget {
  final String text;
  const DisconnectedPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 30,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
