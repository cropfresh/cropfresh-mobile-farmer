import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../services/photo_upload_service.dart';

/// Offline Sync Indicator - Story 3.2 (AC7)
/// 
/// Shows offline status and pending upload count:
/// - OfflineSyncBanner: Full-width banner for offline mode
/// - PendingUploadsBadge: Small badge showing pending count
/// - SyncStatusCard: Detailed card with sync progress

// ============================================================================
// Offline Sync Banner
// ============================================================================

class OfflineSyncBanner extends StatelessWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoUploadService>(
      builder: (context, service, child) {
        if (service.isOnline && service.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          color: service.isOnline 
              ? AppColors.primary.withValues(alpha: 0.9)
              : Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Icon(
                  service.isOnline 
                      ? Icons.cloud_upload
                      : Icons.cloud_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    service.isOnline
                        ? 'Syncing ${service.pendingCount} photo(s)...'
                        : 'Offline - ${service.pendingCount} photo(s) waiting',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (service.isOnline && service.isProcessing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                if (!service.isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Will sync when online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Pending Uploads Badge
// ============================================================================

class PendingUploadsBadge extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const PendingUploadsBadge({
    super.key,
    this.size = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoUploadService>(
      builder: (context, service, child) {
        if (service.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (backgroundColor ?? AppColors.primary)
                    .withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              service.pendingCount > 9 
                  ? '9+' 
                  : '${service.pendingCount}',
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Sync Status Card
// ============================================================================

class SyncStatusCard extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onViewQueue;

  const SyncStatusCard({
    super.key,
    this.onRetry,
    this.onViewQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoUploadService>(
      builder: (context, service, child) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: service.isOnline
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: service.isOnline
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        service.isOnline 
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: service.isOnline 
                            ? AppColors.secondary
                            : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: service.isOnline
                                  ? AppColors.secondary
                                  : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            service.pendingCount == 0
                                ? 'All photos synced'
                                : '${service.pendingCount} photo(s) pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (service.isProcessing)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Current upload progress
              if (service.currentUpload != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.upload,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Uploading ${service.currentUpload!.cropType}...',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${(service.currentProgress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: service.currentProgress,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

              // Actions
              if (service.pendingCount > 0 && !service.isProcessing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      if (onViewQueue != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onViewQueue,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('View Queue'),
                          ),
                        ),
                      if (onViewQueue != null && onRetry != null)
                        const SizedBox(width: 12),
                      if (onRetry != null && service.isOnline)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.sync, size: 18),
                            label: const Text('Sync Now'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// Upload Queue Item Widget
// ============================================================================

class UploadQueueItem extends StatelessWidget {
  final PhotoUploadItem item;
  final VoidCallback? onRetry;
  final VoidCallback? onRemove;

  const UploadQueueItem({
    super.key,
    required this.item,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.cropType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (item.status == PhotoUploadStatus.failed && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: AppColors.primary,
              tooltip: 'Retry',
            ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close),
              color: Colors.grey.shade400,
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (item.status) {
      case PhotoUploadStatus.completed:
        return AppColors.secondary.withValues(alpha: 0.3);
      case PhotoUploadStatus.failed:
        return AppColors.error.withValues(alpha: 0.3);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusColor() {
    switch (item.status) {
      case PhotoUploadStatus.pending:
        return Colors.grey.shade600;
      case PhotoUploadStatus.uploading:
      case PhotoUploadStatus.validating:
        return AppColors.primary;
      case PhotoUploadStatus.completed:
        return AppColors.secondary;
      case PhotoUploadStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (item.status) {
      case PhotoUploadStatus.pending:
        return Icons.schedule;
      case PhotoUploadStatus.uploading:
        return Icons.cloud_upload;
      case PhotoUploadStatus.validating:
        return Icons.verified;
      case PhotoUploadStatus.completed:
        return Icons.check_circle;
      case PhotoUploadStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (item.status) {
      case PhotoUploadStatus.pending:
        return 'Waiting to upload';
      case PhotoUploadStatus.uploading:
        return 'Uploading...';
      case PhotoUploadStatus.validating:
        return 'Validating...';
      case PhotoUploadStatus.completed:
        return 'Uploaded successfully';
      case PhotoUploadStatus.failed:
        return item.errorMessage ?? 'Upload failed';
    }
  }
}
