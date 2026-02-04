import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/providers/subscription_provider.dart';
import 'package:kaboodle_app/services/subscription/subscription_service.dart';
import 'package:kaboodle_app/shared/utils/app_toast.dart';

class ManageSubscriptionBody extends ConsumerStatefulWidget {
  const ManageSubscriptionBody({super.key});

  @override
  ConsumerState<ManageSubscriptionBody> createState() =>
      _ManageSubscriptionBodyState();
}

class _ManageSubscriptionBodyState
    extends ConsumerState<ManageSubscriptionBody> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isRestoring = false;

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);

    final success = await _subscriptionService.restorePurchases();

    if (mounted) {
      setState(() => _isRestoring = false);

      if (success) {
        final hasSubscription =
            await _subscriptionService.hasActiveSubscription();
        if (hasSubscription) {
          _showSuccessToast('Purchases restored successfully!');
          // Refresh subscription provider after restore
          ref.read(subscriptionProvider.notifier).refresh();
        } else {
          _showInfoToast('No previous purchases found.');
        }
      } else {
        _showErrorToast('Failed to restore purchases.');
      }
    }
  }

  Future<void> _handleCancelSubscription() async {
    final success = await _subscriptionService.openSubscriptionManagement();

    if (mounted) {
      if (success) {
        _showInfoToast('Opening subscription management...');
      } else {
        _showErrorToast(
            'Failed to open subscription management. Please visit your App Store or Play Store settings.');
      }
    }
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    AppToast.success(context, message);
  }

  void _showInfoToast(String message) {
    if (!mounted) return;
    AppToast.info(context, message);
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    AppToast.error(context, message);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  String _getStatusDisplayText(SubscriptionStatus status) {
    // Cancelled but still active (until period ends)
    if (status.isPro && status.cancelledAt != null) {
      return 'Cancelled';
    }
    // Active Pro subscription
    if (status.isPro) {
      return 'Active';
    }
    // Expired (was cancelled and period ended)
    if (!status.isPro && status.cancelledAt != null) {
      return 'Expired';
    }
    // Free user
    return 'Free';
  }

  Color _getStatusColor(SubscriptionStatus status, ColorScheme colorScheme) {
    // Cancelled but still active
    if (status.isPro && status.cancelledAt != null) {
      return Colors.orange;
    }
    // Active Pro subscription
    if (status.isPro) {
      return Colors.green;
    }
    // Expired
    if (!status.isPro && status.cancelledAt != null) {
      return colorScheme.error;
    }
    // Free user
    return colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      data: (status) {
        if (status == null) {
          return _buildErrorState(context);
        }
        return _buildContent(context, status);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorState(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load subscription',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(subscriptionProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Current Plan section header with status chip
                Row(
                  children: [
                    Text(
                      'Current Plan',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(context, status),
                  ],
                ),
                const SizedBox(height: 12),

                // Plan card
                _buildPlanCard(context, status),

                const SizedBox(height: 32),

                // Subscription details section
                Text(
                  'Subscription Details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Details card
                _buildDetailsCard(context, status),
              ],
            ),
          ),
        ),

        // Bottom action buttons
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App logo
          SizedBox(
            width: 48,
            height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/kaboodle-logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Plan name and tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaboodle Pro',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.isPro ? 'Premium Subscription' : 'Free Plan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, SubscriptionStatus status) {
    final statusColor = _getStatusColor(status, Theme.of(context).colorScheme);
    final statusText = _getStatusDisplayText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, SubscriptionStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCancelled = status.cancelledAt != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Member since
          _buildDetailRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Member since',
            value: _formatDate(status.startedAt),
            showDivider: true,
          ),
          // Next billing or ends at
          _buildDetailRow(
            context,
            icon: isCancelled
                ? Icons.event_busy_rounded
                : Icons.autorenew_rounded,
            label: isCancelled ? 'Subscription ends' : 'Next billing',
            value: _formatDate(status.expiresAt),
            valueColor: isCancelled ? Colors.orange : null,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Restore Purchases button
            OutlinedButton(
              onPressed: _isRestoring ? null : _handleRestore,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.outline,
                ),
              ),
              child: _isRestoring
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  : Text(
                      'Restore Purchases',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // Cancel Subscription button
            OutlinedButton(
              onPressed: _handleCancelSubscription,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Cancel Subscription',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
