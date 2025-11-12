import 'package:flutter/material.dart';

class EditAppTheme extends StatelessWidget {
  const EditAppTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'App Theme settings will be built here',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
