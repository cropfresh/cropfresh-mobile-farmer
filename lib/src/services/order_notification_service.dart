import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_models.dart';
import 'order_service.dart';

/// Order Notification Service - Story 3.6 (AC: 2, 4)
///
/// Handles order status notifications:
/// - FCM push notification processing
/// - Deep link navigation to order details
/// - In-app snackbar for foreground updates
/// - Badge count updates
class OrderNotificationService {
  // Singleton pattern
  static final OrderNotificationService _instance =
      OrderNotificationService._internal();
  factory OrderNotificationService() => _instance;
  OrderNotificationService._internal();

  final OrderService _orderService = OrderService();

  // Stream controller for in-app notifications
  final StreamController<OrderNotification> _notificationController =
      StreamController<OrderNotification>.broadcast();

  /// Stream of order notifications for UI display
  Stream<OrderNotification> get notifications => _notificationController.stream;

  // Badge count
  int _badgeCount = 0;
  int get badgeCount => _badgeCount;

  // Stream for badge count updates
  final StreamController<int> _badgeController =
      StreamController<int>.broadcast();
  Stream<int> get badgeCountStream => _badgeController.stream;

  /// Initialize notification handling (call in main.dart)
  Future<void> initialize() async {
    // TODO: Setup FCM token and handlers
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    // FirebaseMessaging.instance.getInitialMessage().then(_handleNotificationTap);
    
    // Fetch initial badge count
    await refreshBadgeCount();
  }

  /// Handle foreground FCM message
  void handleForegroundMessage(Map<String, dynamic> message) {
    try {
      final data = message['data'] as Map<String, dynamic>?;
      if (data == null) return;

      final type = data['type'] as String?;
      
      // Only process order-related notifications
      if (type != 'ORDER_STATUS_UPDATE' && type != 'ORDER_DELAY') return;

      // Parse notification
      final notification = OrderNotification.fromFcm(data);
      
      // Update order service cache
      _orderService.handleStatusUpdate(data);
      
      // Emit to UI for snackbar display
      _notificationController.add(notification);
      
      // Update badge count
      refreshBadgeCount();
    } catch (e) {
      debugPrint('OrderNotificationService.handleForegroundMessage error: $e');
    }
  }

  /// Handle notification tap (opens from background/terminated)
  void handleNotificationTap(Map<String, dynamic>? message) {
    if (message == null) return;

    try {
      final data = message['data'] as Map<String, dynamic>?;
      if (data == null) return;

      final orderId = data['order_id'] as String?;
      if (orderId == null) return;

      // Navigate to order details
      // This will be handled by the navigation service
      _notificationController.add(OrderNotification(
        orderId: orderId,
        status: OrderStatusExtension.fromString(data['status'] as String?),
        title: data['title'] as String? ?? 'Order Update',
        body: data['body'] as String? ?? '',
        isDelay: data['type'] == 'ORDER_DELAY',
        shouldNavigate: true,
      ));
    } catch (e) {
      debugPrint('OrderNotificationService.handleNotificationTap error: $e');
    }
  }

  /// Refresh badge count from server
  Future<void> refreshBadgeCount() async {
    try {
      _badgeCount = await _orderService.getActiveOrderCount();
      _badgeController.add(_badgeCount);
    } catch (e) {
      debugPrint('OrderNotificationService.refreshBadgeCount error: $e');
    }
  }

  /// Clear badge count (e.g., when viewing orders)
  void clearBadgeCount() {
    _badgeCount = 0;
    _badgeController.add(0);
  }

  /// Generate deep link route for order
  String getOrderDeepLink(String orderId) {
    return '/orders/$orderId';
  }

  /// Dispose streams
  void dispose() {
    _notificationController.close();
    _badgeController.close();
  }
}

/// Order notification data model
class OrderNotification {
  final String orderId;
  final OrderStatus status;
  final String title;
  final String body;
  final bool isDelay;
  final int? delayMinutes;
  final DateTime? updatedEta;
  final bool shouldNavigate;

  const OrderNotification({
    required this.orderId,
    required this.status,
    required this.title,
    required this.body,
    this.isDelay = false,
    this.delayMinutes,
    this.updatedEta,
    this.shouldNavigate = false,
  });

  factory OrderNotification.fromFcm(Map<String, dynamic> data) {
    return OrderNotification(
      orderId: data['order_id'] as String? ?? '',
      status: OrderStatusExtension.fromString(data['status'] as String?),
      title: data['title'] as String? ?? 'Order Update',
      body: data['body'] as String? ?? '',
      isDelay: data['type'] == 'ORDER_DELAY',
      delayMinutes: data['delay_minutes'] as int?,
      updatedEta: DateTime.tryParse(data['updated_eta'] as String? ?? ''),
      shouldNavigate: false,
    );
  }

  /// Get snackbar message for in-app display
  String get snackbarMessage {
    if (isDelay) {
      return 'Order delayed by ${delayMinutes ?? 0} minutes';
    }
    return 'Order status: ${status.label}';
  }

  /// Get icon for notification type
  String get iconName {
    if (isDelay) return 'warning_amber_rounded';
    return status.iconName;
  }
}
