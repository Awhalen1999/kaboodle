import 'package:kaboodle_app/features/auth/widgets/welcome_body.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffold(
      body: Scaffold(
        body: SafeArea(
          child: WelcomeBody(),
        ),
      ),
    );
  }
}
