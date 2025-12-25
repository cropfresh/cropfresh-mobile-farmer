// Notification Models - Story 3.8
//
// Models for farmer notifications, preferences, and push handling.
// Follows Material Design 3 principles with Voice-First support.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =============================================================================
// NOTIFICATION TYPES
// =============================================================================

/// Notification type enum matching backend NotificationType proto
enum NotificationType {
  // Critical - SMS + Push
  orderMatched,
  paymentReceived,
  matchExpiring,
  orderCancelled,
  qualityDispute,
  
  // Important - Push only
  haulerEnRoute,
  pickupComplete,
  delivered,
  dropPointAssigned,
  matchExpired,
  
  // Low priority
  educationalContent,
}

extension NotificationTypeExtension on NotificationType {
  /// Display title for the notification type
  String get title {
    switch (this) {
      case NotificationType.orderMatched:
        return 'Buyer found!';
      case NotificationType.paymentReceived:
        return 'Payment received';
      case NotificationType.matchExpiring:
        return 'Match expiring soon';
      case NotificationType.orderCancelled:
        return 'Order cancelled';
      case NotificationType.qualityDispute:
        return 'Quality issue';
      case NotificationType.haulerEnRoute:
        return 'Hauler on the way';
      case NotificationType.pickupComplete:
        return 'Pickup complete';
      case NotificationType.delivered:
        return 'Delivered';
      case NotificationType.dropPointAssigned:
        return 'Drop point assigned';
      case NotificationType.matchExpired:
        return 'Match expired';
      case NotificationType.educationalContent:
        return 'New tip';
    }
  }

  /// Icon for the notification type
  IconData get icon {
    switch (this) {
      case NotificationType.orderMatched:
        return Icons.handshake;
      case NotificationType.paymentReceived:
        return Icons.payments;
      case NotificationType.matchExpiring:
        return Icons.timer;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.qualityDispute:
        return Icons.warning_amber;
      case NotificationType.haulerEnRoute:
        return Icons.local_shipping;
      case NotificationType.pickupComplete:
        return Icons.inventory_2;
      case NotificationType.delivered:
        return Icons.check_circle;
      case NotificationType.dropPointAssigned:
        return Icons.location_on;
      case NotificationType.matchExpired:
        return Icons.timer_off;
      case NotificationType.educationalContent:
        return Icons.lightbulb;
    }
  }

  /// Color theme for the notification type
  Color get color {
    switch (this) {
      case NotificationType.orderMatched:
        return const Color(0xFF2E7D32); // Green - success
      case NotificationType.paymentReceived:
        return const Color(0xFF2E7D32); // Green - success
      case NotificationType.matchExpiring:
        return const Color(0xFFF57C00); // Orange - warning
      case NotificationType.orderCancelled:
        return const Color(0xFFB3261E); // Red - error
      case NotificationType.qualityDispute:
        return const Color(0xFFB3261E); // Red - error
      case NotificationType.haulerEnRoute:
        return const Color(0xFF1976D2); // Blue - info
      case NotificationType.pickupComplete:
        return const Color(0xFF1976D2); // Blue - info
      case NotificationType.delivered:
        return const Color(0xFF2E7D32); // Green - success
      case NotificationType.dropPointAssigned:
        return const Color(0xFF1976D2); // Blue - info
      case NotificationType.matchExpired:
        return const Color(0xFF79747E); // Grey - neutral
      case NotificationType.educationalContent:
        return const Color(0xFF7B1FA2); // Purple - educational
    }
  }

  /// Whether this is a critical notification (SMS + Push)
  bool get isCritical {
    switch (this) {
      case NotificationType.orderMatched:
      case NotificationType.paymentReceived:
      case NotificationType.matchExpiring:
      case NotificationType.orderCancelled:
      case NotificationType.qualityDispute:
        return true;
      default:
        return false;
    }
  }

  /// API value for backend communication
  String get apiValue {
    switch (this) {
      case NotificationType.orderMatched:
        return 'ORDER_MATCHED';
      case NotificationType.paymentReceived:
        return 'PAYMENT_RECEIVED';
      case NotificationType.matchExpiring:
        return 'MATCH_EXPIRING';
      case NotificationType.orderCancelled:
        return 'ORDER_CANCELLED';
      case NotificationType.qualityDispute:
        return 'QUALITY_DISPUTE';
      case NotificationType.haulerEnRoute:
        return 'HAULER_EN_ROUTE';
      case NotificationType.pickupComplete:
        return 'PICKUP_COMPLETE';
      case NotificationType.delivered:
        return 'DELIVERED';
      case NotificationType.dropPointAssigned:
        return 'DROP_POINT_ASSIGNED';
      case NotificationType.matchExpired:
        return 'MATCH_EXPIRED';
      case NotificationType.educationalContent:
        return 'EDUCATIONAL_CONTENT';
    }
  }

  /// Parse notification type from API string
  static NotificationType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ORDER_MATCHED':
        return NotificationType.orderMatched;
      case 'PAYMENT_RECEIVED':
        return NotificationType.paymentReceived;
      case 'MATCH_EXPIRING':
        return NotificationType.matchExpiring;
      case 'ORDER_CANCELLED':
        return NotificationType.orderCancelled;
      case 'QUALITY_DISPUTE':
        return NotificationType.qualityDispute;
      case 'HAULER_EN_ROUTE':
        return NotificationType.haulerEnRoute;
      case 'PICKUP_COMPLETE':
        return NotificationType.pickupComplete;
      case 'DELIVERED':
        return NotificationType.delivered;
      case 'DROP_POINT_ASSIGNED':
        return NotificationType.dropPointAssigned;
      case 'MATCH_EXPIRED':
        return NotificationType.matchExpired;
      case 'EDUCATIONAL_CONTENT':
        return NotificationType.educationalContent;
      default:
        return NotificationType.educationalContent;
    }
  }
}

// =============================================================================
// NOTIFICATION LEVEL
// =============================================================================

/// Notification level for preferences
enum NotificationLevel {
  all,
  criticalOnly,
  mute,
}

extension NotificationLevelExtension on NotificationLevel {
  String get label {
    switch (this) {
      case NotificationLevel.all:
        return 'All';
      case NotificationLevel.criticalOnly:
        return 'Critical only';
      case NotificationLevel.mute:
        return 'Mute';
    }
  }

  String get description {
    switch (this) {
      case NotificationLevel.all:
        return 'Receive all notifications';
      case NotificationLevel.criticalOnly:
        return 'Only match and payment alerts';
      case NotificationLevel.mute:
        return 'No notifications';
    }
  }

  String get apiValue {
    switch (this) {
      case NotificationLevel.all:
        return 'all';
      case NotificationLevel.criticalOnly:
        return 'critical';
      case NotificationLevel.mute:
        return 'mute';
    }
  }

  static NotificationLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'all':
        return NotificationLevel.all;
      case 'critical':
        return NotificationLevel.criticalOnly;
      case 'mute':
        return NotificationLevel.mute;
      default:
        return NotificationLevel.all;
    }
  }
}

// =============================================================================
// APP NOTIFICATION MODEL
// =============================================================================

/// Individual notification item (AC3)
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? deeplink;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.deeplink,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: NotificationTypeExtension.fromString(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      deeplink: json['deeplink'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? 
                 DateTime.tryParse(json['createdAt'] as String? ?? '') ?? 
                 DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.apiValue,
    'title': title,
    'body': body,
    if (deeplink != null) 'deeplink': deeplink,
    if (metadata != null) 'metadata': metadata,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? deeplink,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      deeplink: deeplink ?? this.deeplink,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================
  // Formatted Getters
  // ============================================

  /// Relative timestamp for display (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(createdAt);
    }
  }

  /// Absolute timestamp for detail view
  String get formattedDate => DateFormat('MMM d, yyyy h:mm a').format(createdAt);

  /// Icon for this notification
  IconData get icon => type.icon;

  /// Color for this notification
  Color get color => type.color;

  /// Whether this is a critical notification
  bool get isCritical => type.isCritical;

  /// TTS announcement for voice-first UX (AC8)
  String get ttsAnnouncement {
    return '$title. $body. $relativeTime.';
  }

  /// Semantic label for accessibility
  String get semanticLabel {
    final readStatus = isRead ? 'Read' : 'Unread';
    return '$readStatus notification. $title. $body. $relativeTime.';
  }

  // ============================================
  // Metadata Helpers
  // ============================================

  /// Get order ID from metadata
  String? get orderId => metadata?['order_id'] as String? ?? metadata?['orderId'] as String?;

  /// Get amount from metadata
  double? get amount {
    final value = metadata?['amount'];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Get formatted amount
  String? get formattedAmount {
    final amt = amount;
    if (amt == null) return null;
    return NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN').format(amt);
  }

  /// Get crop type from metadata
  String? get cropType => metadata?['crop_type'] as String? ?? metadata?['cropType'] as String?;

  /// Get quantity from metadata
  double? get quantity {
    final value = metadata?['quantity'] ?? metadata?['quantity_kg'] ?? metadata?['quantityKg'];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ============================================
  // Mock Factory
  // ============================================

  factory AppNotification.mock({
    NotificationType type = NotificationType.orderMatched,
    bool isRead = false,
    int hoursAgo = 2,
  }) {
    final id = 'NOTIF-${DateTime.now().millisecondsSinceEpoch}';
    
    String title;
    String body;
    String? deeplink;
    Map<String, dynamic>? metadata;

    switch (type) {
      case NotificationType.orderMatched:
        title = 'Buyer found!';
        body = 'Accept match for 50kg Tomatoes at ₹36/kg';
        deeplink = '/match-details';
        metadata = {'order_id': 'ORD-123', 'crop_type': 'Tomato', 'quantity': 50, 'amount': 1800};
        break;
      case NotificationType.paymentReceived:
        title = 'Payment received';
        body = '₹1,800 received for Tomatoes. Check UPI.';
        deeplink = '/earnings';
        metadata = {'order_id': 'ORD-123', 'amount': 1800, 'upi_txn_id': 'ABCD1234'};
        break;
      case NotificationType.matchExpiring:
        title = 'Match expiring soon';
        body = 'Accept match within 2 hours or it expires.';
        deeplink = '/match-details';
        metadata = {'order_id': 'ORD-123', 'expires_in_hours': 2};
        break;
      case NotificationType.orderCancelled:
        title = 'Order cancelled';
        body = 'Your tomato order was cancelled by the buyer.';
        deeplink = '/orders';
        metadata = {'order_id': 'ORD-123', 'reason': 'Buyer cancelled'};
        break;
      case NotificationType.haulerEnRoute:
        title = 'Hauler on the way';
        body = 'Arriving at drop point in 30 minutes.';
        deeplink = '/drop-point';
        metadata = {'order_id': 'ORD-123', 'eta_minutes': 30};
        break;
      case NotificationType.dropPointAssigned:
        title = 'Drop point assigned';
        body = 'Deliver to Kolar Drop Point tomorrow 7-9 AM';
        deeplink = '/drop-point';
        metadata = {'drop_point_name': 'Kolar Drop Point', 'time_window': '7-9 AM'};
        break;
      default:
        title = type.title;
        body = 'This is a notification message.';
        deeplink = null;
        metadata = null;
    }

    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      deeplink: deeplink,
      metadata: metadata,
      isRead: isRead,
      createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
    );
  }
}

// =============================================================================
// NOTIFICATION PREFERENCES MODEL
// =============================================================================

/// Farmer notification preferences (AC4)
class NotificationPreferences {
  final bool smsEnabled;
  final bool pushEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final bool quietHoursEnabled;
  final NotificationLevel level;
  final bool orderUpdates;
  final bool paymentAlerts;
  final bool educationalContent;

  const NotificationPreferences({
    this.smsEnabled = true,
    this.pushEnabled = true,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0), // 10 PM
    this.quietHoursEnd = const TimeOfDay(hour: 6, minute: 0),     // 6 AM
    this.quietHoursEnabled = true,
    this.level = NotificationLevel.all,
    this.orderUpdates = true,
    this.paymentAlerts = true,
    this.educationalContent = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      smsEnabled: json['sms_enabled'] as bool? ?? json['smsEnabled'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? json['pushEnabled'] as bool? ?? true,
      quietHoursStart: _parseTimeOfDay(json['quiet_hours_start'] ?? json['quietHoursStart']) ?? const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: _parseTimeOfDay(json['quiet_hours_end'] ?? json['quietHoursEnd']) ?? const TimeOfDay(hour: 6, minute: 0),
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? json['quietHoursEnabled'] as bool? ?? true,
      level: NotificationLevelExtension.fromString(json['notification_level'] as String? ?? json['notificationLevel'] as String?),
      orderUpdates: json['order_updates'] as bool? ?? json['orderUpdates'] as bool? ?? true,
      paymentAlerts: json['payment_alerts'] as bool? ?? json['paymentAlerts'] as bool? ?? true,
      educationalContent: json['educational_content'] as bool? ?? json['educationalContent'] as bool? ?? true,
    );
  }

  static TimeOfDay? _parseTimeOfDay(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    return null;
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'sms_enabled': smsEnabled,
    'push_enabled': pushEnabled,
    'quiet_hours_start': _formatTimeOfDay(quietHoursStart),
    'quiet_hours_end': _formatTimeOfDay(quietHoursEnd),
    'quiet_hours_enabled': quietHoursEnabled,
    'notification_level': level.apiValue,
    'order_updates': orderUpdates,
    'payment_alerts': paymentAlerts,
    'educational_content': educationalContent,
  };

  NotificationPreferences copyWith({
    bool? smsEnabled,
    bool? pushEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? quietHoursEnabled,
    NotificationLevel? level,
    bool? orderUpdates,
    bool? paymentAlerts,
    bool? educationalContent,
  }) {
    return NotificationPreferences(
      smsEnabled: smsEnabled ?? this.smsEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      level: level ?? this.level,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      educationalContent: educationalContent ?? this.educationalContent,
    );
  }

  // ============================================
  // Formatted Getters
  // ============================================

  /// Format quiet hours for display (e.g., "10:00 PM - 6:00 AM")
  String get quietHoursDisplay {
    final startFormatted = _formatTime12Hour(quietHoursStart);
    final endFormatted = _formatTime12Hour(quietHoursEnd);
    return '$startFormatted - $endFormatted';
  }

  static String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Check if current time is within quiet hours
  bool get isQuietHoursNow {
    if (!quietHoursEnabled) return false;
    
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = quietHoursStart.hour * 60 + quietHoursStart.minute;
    final endMinutes = quietHoursEnd.hour * 60 + quietHoursEnd.minute;

    // Handle overnight quiet hours (e.g., 10 PM to 6 AM)
    if (startMinutes > endMinutes) {
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  /// TTS announcement for settings
  String get ttsAnnouncement {
    final parts = <String>[];
    parts.add('Notification settings.');
    parts.add('SMS is ${smsEnabled ? "enabled" : "disabled"}.');
    parts.add('Push is ${pushEnabled ? "enabled" : "disabled"}.');
    if (quietHoursEnabled) {
      parts.add('Quiet hours from ${_formatTime12Hour(quietHoursStart)} to ${_formatTime12Hour(quietHoursEnd)}.');
    }
    parts.add('Level is ${level.label}.');
    return parts.join(' ');
  }

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences();
  }
}

// =============================================================================
// NOTIFICATIONS RESPONSE MODEL
// =============================================================================

/// Paginated notifications response
class NotificationsResponse {
  final List<AppNotification> notifications;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unreadCount: json['unread_count'] as int? ?? json['unreadCount'] as int? ?? 0,
      page: json['pagination']?['page'] as int? ?? json['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? json['limit'] as int? ?? 20,
      total: json['pagination']?['total'] as int? ?? json['total'] as int? ?? 0,
      hasMore: json['pagination']?['has_more'] as bool? ?? json['hasMore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'notifications': notifications.map((n) => n.toJson()).toList(),
    'unread_count': unreadCount,
    'pagination': {
      'page': page,
      'limit': limit,
      'total': total,
      'has_more': hasMore,
    },
  };

  bool get isEmpty => notifications.isEmpty;
  int get nextPage => page + 1;

  /// TTS announcement for voice-first UX (AC8)
  String get ttsAnnouncement {
    if (unreadCount == 0) {
      return 'You have no unread notifications.';
    } else if (unreadCount == 1) {
      return 'You have 1 unread notification.';
    } else {
      return 'You have $unreadCount unread notifications.';
    }
  }

  factory NotificationsResponse.mock({int count = 10, int unread = 3}) {
    final types = [
      NotificationType.orderMatched,
      NotificationType.paymentReceived,
      NotificationType.haulerEnRoute,
      NotificationType.dropPointAssigned,
      NotificationType.delivered,
    ];

    return NotificationsResponse(
      notifications: List.generate(
        count,
        (i) => AppNotification.mock(
          type: types[i % types.length],
          isRead: i >= unread,
          hoursAgo: i * 3 + 1,
        ),
      ),
      unreadCount: unread,
      page: 1,
      limit: 20,
      total: count,
      hasMore: count >= 20,
    );
  }

  factory NotificationsResponse.empty() {
    return const NotificationsResponse(
      notifications: [],
      unreadCount: 0,
      page: 1,
      limit: 20,
      total: 0,
      hasMore: false,
    );
  }
}

// =============================================================================
// NOTIFICATION FILTER MODEL
// =============================================================================

/// Filter options for notification list
class NotificationFilter {
  final bool unreadOnly;
  final NotificationType? type;
  final int page;
  final int limit;

  const NotificationFilter({
    this.unreadOnly = false,
    this.type,
    this.page = 1,
    this.limit = 20,
  });

  NotificationFilter copyWith({
    bool? unreadOnly,
    NotificationType? type,
    int? page,
    int? limit,
  }) {
    return NotificationFilter(
      unreadOnly: unreadOnly ?? this.unreadOnly,
      type: type ?? this.type,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      if (unreadOnly) 'unread_only': 'true',
      if (type != null) 'type': type!.apiValue,
      'page': page.toString(),
      'limit': limit.toString(),
    };
  }
}
