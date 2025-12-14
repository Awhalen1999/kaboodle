import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;

  static const String _privacyPolicyUrl = 'https://kaboodle.app/privacy';
  static const String _termsUrl = 'https://kaboodle.app/terms';

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
        _selectedPackage = _findYearlyPackage(packages) ?? packages.firstOrNull;
        _isLoading = false;
      });
    }
  }

  Package? _findYearlyPackage(List<Package> packages) {
    for (final package in packages) {
      if (package.packageType == PackageType.annual ||
          package.storeProduct.identifier.toLowerCase().contains('year')) {
        return package;
      }
    }
    return null;
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);

    final success =
        await _subscriptionService.purchasePackage(_selectedPackage!);

    if (mounted) {
      setState(() => _isPurchasing = false);

      if (success) {
        _showSuccessToast('Welcome to Kaboodle Pro!');
        context.pop();
      } else {
        _showErrorToast('Purchase failed. Please try again.');
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

  void _handleLegalLinkTap(String url) {
    debugPrint('Legal link tapped: $url');
    // TODO: Implement URL launching when ready
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(theme),

                        // Flexible space - expands on tall phones, collapses on short
                        const Spacer(),

                        // Animation (fixed height)
                        SizedBox(
                          height: 220,
                          child: Lottie.asset(
                            'assets/lottie/loving_cat.json',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Unlock unlimited packing lists\nwith Kaboodle Pro',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Package tiles
                        _buildPackageTiles(theme, colorScheme),

                        const SizedBox(height: 24),

                        // Cancel anytime text
                        Text(
                          'Cancel anytime in the App Store',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subscribe button
                        _buildSubscribeButton(theme, colorScheme),

                        const SizedBox(height: 4),

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
                        const SizedBox(height: 12),

                        // Legal text
                        _buildLegalText(theme, colorScheme),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Kaboodle',
            style: theme.textTheme.headlineLarge,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTiles(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      );
    }

    if (_packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No subscription options available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: Row(
        children: _packages.map((package) {
          final index = _packages.indexOf(package);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == _packages.length - 1 ? 0 : 6,
              ),
              child: _buildPackageCard(package, theme, colorScheme),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackageCard(
    Package package,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final product = package.storeProduct;
    final isSelected = _selectedPackage == package;
    final isYearly = package.packageType == PackageType.annual ||
        product.identifier.toLowerCase().contains('year');

    return GestureDetector(
      onTap: _isPurchasing
          ? null
          : () => setState(() => _selectedPackage = package),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPackageTitle(package),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildCheckbox(isSelected, colorScheme),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        product.priceString,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      isYearly ? '/yr' : '/mo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (isYearly) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getMonthlyEquivalent(product),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isYearly)
            Positioned(
              top: -10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Save 20%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isSelected, ColorScheme colorScheme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              size: 14,
              color: colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildSubscribeButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isPurchasing || _selectedPackage == null ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                'Subscribe',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLegalText(ThemeData theme, ColorScheme colorScheme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontSize: 11,
      height: 1.4,
    );

    final linkStyle = textStyle?.copyWith(
      decoration: TextDecoration.underline,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: textStyle,
          children: [
            const TextSpan(
              text:
                  'Subscription automatically renews unless canceled at least 24 hours before the end of the current period. ',
            ),
            TextSpan(
              text: 'Terms of Use',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _handleLegalLinkTap(_termsUrl),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _handleLegalLinkTap(_privacyPolicyUrl),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  String _getMonthlyEquivalent(StoreProduct product) {
    final price = product.price;
    final monthlyPrice = price / 12;
    return '\$${monthlyPrice.toStringAsFixed(2)}/mo';
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.annual:
        return 'Yearly';
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.weekly:
        return 'Weekly';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return package.storeProduct.title;
    }
  }
}
