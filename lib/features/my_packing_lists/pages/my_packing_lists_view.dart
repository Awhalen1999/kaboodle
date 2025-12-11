import 'package:kaboodle_app/features/my_packing_lists/widgets/my_packing_lists_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/providers/trips_provider.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/shared/widgets/menu_drawer.dart';
import 'package:kaboodle_app/services/subscription/subscription_service.dart';

class MyPackingListsView extends ConsumerStatefulWidget {
  final String? initialTab;

  const MyPackingListsView({super.key, this.initialTab});

  @override
  ConsumerState<MyPackingListsView> createState() => _MyPackingListsViewState();
}

class _MyPackingListsViewState extends ConsumerState<MyPackingListsView> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isCheckingSubscription = false;

  Future<void> _handleCreateList() async {
    if (_isCheckingSubscription) return;

    setState(() => _isCheckingSubscription = true);

    try {
      final result = await _subscriptionService.canCreateList();

      if (!mounted) return;

      if (result == null) {
        // API call failed, allow user to proceed (fail open)
        // The backend will do the final check anyway
        context.push('/create-packing-list');
        return;
      }

      if (result.canCreate) {
        context.push('/create-packing-list');
      } else {
        // Show paywall
        _subscriptionService.showPaywall(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingSubscription = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers - AsyncNotifier automatically loads data when first accessed
    debugPrint('👀 [MyPackingListsView] Watching providers');
    ref.watch(userProvider);
    ref.watch(packingListsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Packing Lists',
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const MenuDrawer(),
      body: MyPackingListsBody(initialTab: widget.initialTab),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCheckingSubscription ? null : _handleCreateList,
        child: _isCheckingSubscription
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
