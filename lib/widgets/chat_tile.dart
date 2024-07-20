import 'package:flutter/material.dart';
import 'package:pchat_app/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final void Function()? onTap;
  ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: false,
      leading: CircleAvatar(backgroundImage: NetworkImage(userProfile.pfpURL!)),
      title: Text(userProfile.name!),
    );
  }
}
