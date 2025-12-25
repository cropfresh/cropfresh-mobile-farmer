import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_models.dart';

/// Push Notification Service - Story 3.8 (Task 10)
///
/// Handles FCM push notifications with:
/// - Token management and refresh (AC7)
/// - Foreground notification display (AC7)
/// - Background notification handling (AC7)
/// - Deep link navigation from notification tap (AC7)
/// - Badge count synchronization (AC3)
///
/// Note: Firebase Messaging integration requires Firebase setup.
/// This service provides the base structure and mock implementation.

class PushNotificationService extends ChangeNotifier {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // FCM token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Unread count for badge
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Notification stream for in-app handling
  final _notificationController = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notificationStream => _notificationController.stream;

  // Token refresh stream
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _tokenController.stream;

  // Initialization state
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the push notification service
  /// 
  /// This should be called early in app startup, typically in main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: Replace with actual Firebase Messaging initialization
      // await Firebase.initializeApp();
      // await FirebaseMessaging.instance.requestPermission();
      
      // Get initial token
      await _getToken();

      // Listen for token refresh
      _setupTokenRefresh();

      // Configure message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      debugPrint('PushNotificationService: Initialized');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to initialize - $e');
    }
  }

  /// Get the current FCM token
  Future<String?> _getToken() async {
    try {
      // TODO: Replace with actual Firebase Messaging token retrieval
      // _fcmToken = await FirebaseMessaging.instance.getToken();
      
      // Mock token for development
      _fcmToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('PushNotificationService: Got token - $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to get token - $e');
      return null;
    }
  }

  /// Get or refresh the FCM token
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    return _getToken();
  }

  /// Register the device token with the backend
  Future<bool> registerToken() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      // TODO: Call API to register device token
      // await notificationApiService.registerDeviceToken(token, 'android');
      
      debugPrint('PushNotificationService: Token registered');
      return true;
    } catch (e) {
      debugPrint('PushNotificationService: Failed to register token - $e');
      return false;
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefresh() {
    // TODO: Replace with actual Firebase Messaging token refresh listener
    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    //   _fcmToken = newToken;
    //   _tokenController.add(newToken);
    //   registerToken();
    // });
  }

  /// Setup message handlers for foreground/background
  void _setupMessageHandlers() {
    // TODO: Replace with actual Firebase Messaging handlers
    
    // Foreground messages
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background message opened
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check for initial message (app opened from terminated state)
    // _checkInitialMessage();
  }

  /// Handle foreground message
  Future<void> handleForegroundMessage(Map<String, dynamic> data) async {
    debugPrint('PushNotificationService: Foreground message received');

    final notification = _parseNotification(data);
    if (notification == null) return;

    // Add to stream for in-app handling
    _notificationController.add(notification);

    // Update badge count
    if (!notification.isRead) {
      updateUnreadCount(_unreadCount + 1);
    }

    // TODO: Show local notification using flutter_local_notifications
    // await _showLocalNotification(notification);
  }

  /// Handle background/terminated state message when user taps notification
  Future<void> handleMessageOpenedApp(Map<String, dynamic> data) async {
    debugPrint('PushNotificationService: Message opened app');

    final notification = _parseNotification(data);
    if (notification == null) return;

    // Navigate to deep link
    if (notification.deeplink != null) {
      navigateToDeeplink(notification.deeplink!);
    }
  }

  /// Parse notification from FCM data
  AppNotification? _parseNotification(Map<String, dynamic> data) {
    try {
      // Extract notification data
      final notificationData = data['data'] ?? data;
      
      return AppNotification(
        id: notificationData['notification_id'] as String? ?? 
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationTypeExtension.fromString(
          notificationData['type'] as String? ?? notificationData['notification_type'] as String?,
        ),
        title: notificationData['title'] as String? ?? 
               data['notification']?['title'] as String? ?? 
               'Notification',
        body: notificationData['body'] as String? ?? 
              data['notification']?['body'] as String? ?? 
              '',
        deeplink: notificationData['deeplink'] as String? ?? 
                  notificationData['click_action'] as String?,
        metadata: notificationData['metadata'] != null
            ? Map<String, dynamic>.from(notificationData['metadata'] as Map)
            : null,
        isRead: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('PushNotificationService: Failed to parse notification - $e');
      return null;
    }
  }

  /// Parse deep link route from notification
  String parseDeeplink(Map<String, dynamic> data) {
    // Priority: deeplink > click_action > type-based default
    final deeplink = data['deeplink'] as String? ?? 
                     data['click_action'] as String?;
    
    if (deeplink != null) return deeplink;

    // Fallback based on notification type
    final type = NotificationTypeExtension.fromString(
      data['type'] as String? ?? data['notification_type'] as String?,
    );

    switch (type) {
      case NotificationType.orderMatched:
      case NotificationType.matchExpiring:
        return '/match-details';
      case NotificationType.paymentReceived:
        return '/earnings';
      case NotificationType.dropPointAssigned:
        return '/drop-point';
      case NotificationType.orderCancelled:
      case NotificationType.delivered:
        return '/orders';
      default:
        return '/notifications';
    }
  }

  /// Navigate to deep link
  /// 
  /// This should be called from the app's navigation context
  void navigateToDeeplink(String route) {
    // This event should be listened to by the app's navigator
    debugPrint('PushNotificationService: Navigating to $route');
    
    // TODO: Use a navigator key or route observer to perform navigation
    // NavigatorKey.currentState?.pushNamed(route);
  }

  /// Update badge count
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();

    // TODO: Update app badge using flutter_app_badger
    // FlutterAppBadger.updateBadgeCount(count);
    
    debugPrint('PushNotificationService: Badge count updated to $count');
  }

  /// Sync badge count with backend
  Future<void> syncUnreadCount() async {
    try {
      // TODO: Call API to get unread count
      // final response = await notificationApiService.getNotifications(limit: 1);
      // updateUnreadCount(response.unreadCount);
      
      debugPrint('PushNotificationService: Badge count synced');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to sync badge count - $e');
    }
  }

  /// Clear badge count
  void clearBadge() {
    updateUnreadCount(0);
    
    // TODO: Clear app badge
    // FlutterAppBadger.removeBadge();
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      // TODO: Replace with actual Firebase Messaging permission request
      // final settings = await FirebaseMessaging.instance.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );
      // return settings.authorizationStatus == AuthorizationStatus.authorized;
      
      return true; // Mock success
    } catch (e) {
      debugPrint('PushNotificationService: Failed to request permission - $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // TODO: Replace with actual Firebase Messaging settings check
      // final settings = await FirebaseMessaging.instance.getNotificationSettings();
      // return settings.authorizationStatus == AuthorizationStatus.authorized;
      
      return true; // Mock enabled
    } catch (e) {
      return false;
    }
  }

  /// Subscribe to topic for broadcast notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      // TODO: Replace with actual Firebase Messaging topic subscription
      // await FirebaseMessaging.instance.subscribeToTopic(topic);
      
      debugPrint('PushNotificationService: Subscribed to topic $topic');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to subscribe to topic - $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // TODO: Replace with actual Firebase Messaging topic unsubscription
      // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      
      debugPrint('PushNotificationService: Unsubscribed from topic $topic');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to unsubscribe from topic - $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _notificationController.close();
    _tokenController.close();
    super.dispose();
  }
}

// Singleton instance
final pushNotificationService = PushNotificationService();
