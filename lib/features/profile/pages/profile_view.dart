import 'package:kaboodle_app/features/profile/widgets/profile_body.dart';
import 'package:flutter/material.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ProfileBody(),
      ),
    );
  }
}
