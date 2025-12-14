import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/features/manage_subscription/widgets/manage_subscription_body.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';

class ManageSubscriptionView extends ConsumerWidget {
  const ManageSubscriptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Manage Subscription',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const ManageSubscriptionBody(),
    );
  }
}
