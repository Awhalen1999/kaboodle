import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:kaboodle_app/services/subscription/subscription_service.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await _subscriptionService.getPackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() => _isPurchasing = true);

    final success = await _subscriptionService.purchasePackage(package);

    if (mounted) {
      setState(() => _isPurchasing = false);

      if (success) {
        _showSuccessToast('Welcome to Kaboodle Pro!');
        context.pop();
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);

    final success = await _subscriptionService.restorePurchases();

    if (mounted) {
      setState(() => _isPurchasing = false);

      if (success) {
        final hasSubscription =
            await _subscriptionService.hasActiveSubscription();
        if (hasSubscription) {
          _showSuccessToast('Purchases restored!');
          context.pop();
        } else {
          _showInfoToast('No previous purchases found.');
        }
      } else {
        _showErrorToast('Failed to restore purchases.');
      }
    }
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(message),
    );
  }

  void _showInfoToast(String message) {
    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(message),
    );
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Upgrade to Pro',
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock unlimited packing lists',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Benefits
                    _buildBenefitItem(
                      context,
                      Icons.all_inclusive,
                      'Unlimited Packing Lists',
                      'Create as many lists as you need',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      Icons.cloud_sync,
                      'Sync Across Devices',
                      'Access your lists anywhere',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      Icons.support_agent,
                      'Priority Support',
                      'Get help when you need it',
                    ),
                    const SizedBox(height: 40),

                    // Packages
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_packages.isEmpty)
                      Text(
                        'No subscription options available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ..._packages.map((package) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPackageButton(context, package),
                          )),

                    const SizedBox(height: 24),

                    // Restore purchases
                    TextButton(
                      onPressed: _isPurchasing ? null : _handleRestore,
                      child: Text(
                        'Restore Purchases',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageButton(BuildContext context, Package package) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = package.storeProduct;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : () => _handlePurchase(package),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isPurchasing
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                '${product.title} - ${product.priceString}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

