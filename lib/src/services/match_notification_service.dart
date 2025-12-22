// Match Notification Service - Story 3.5 (AC: 1, 5, 8)
// Handles push notification delivery, in-app banners, and TTS announcements.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/match_models.dart';

/// Match notification types
enum MatchNotificationType {
  newMatch,
  matchExpirySoon,
  matchExpired,
  matchAccepted,
  matchRejected,
}

extension MatchNotificationTypeExtension on MatchNotificationType {
  String get title {
    switch (this) {
      case MatchNotificationType.newMatch:
        return 'Buyer found!';
      case MatchNotificationType.matchExpirySoon:
        return 'Match expiring soon';
      case MatchNotificationType.matchExpired:
        return 'Match expired';
      case MatchNotificationType.matchAccepted:
        return 'Match accepted';
      case MatchNotificationType.matchRejected:
        return 'Match declined';
    }
  }

  IconData get icon {
    switch (this) {
      case MatchNotificationType.newMatch:
        return Icons.handshake;
      case MatchNotificationType.matchExpirySoon:
        return Icons.timer;
      case MatchNotificationType.matchExpired:
        return Icons.timer_off;
      case MatchNotificationType.matchAccepted:
        return Icons.check_circle;
      case MatchNotificationType.matchRejected:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case MatchNotificationType.newMatch:
        return const Color(0xFF2E7D32); // Green
      case MatchNotificationType.matchExpirySoon:
        return const Color(0xFFF57C00); // Orange
      case MatchNotificationType.matchExpired:
        return const Color(0xFFB3261E); // Error red
      case MatchNotificationType.matchAccepted:
        return const Color(0xFF2E7D32); // Green
      case MatchNotificationType.matchRejected:
        return const Color(0xFF79747E); // Neutral
    }
  }
}

/// In-app notification data
class MatchNotification {
  final String id;
  final MatchNotificationType type;
  final Match? match;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const MatchNotification({
    required this.id,
    required this.type,
    this.match,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  MatchNotification copyWith({bool? isRead}) {
    return MatchNotification(
      id: id,
      type: type,
      match: match,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Service for handling match notifications (AC: 1, 5)
/// 
/// Provides:
/// - FCM push notification parsing
/// - In-app notification banners
/// - TTS announcements for match details
/// - Notification badge count management
class MatchNotificationService extends ChangeNotifier {
  static final MatchNotificationService _instance = MatchNotificationService._internal();
  factory MatchNotificationService() => _instance;
  MatchNotificationService._internal();

  final FlutterTts _tts = FlutterTts();
  final List<MatchNotification> _notifications = [];
  int _pendingMatchCount = 0;
  bool _ttsEnabled = true;
  String _language = 'en-IN';

  // Stream for notification events
  final _notificationController = StreamController<MatchNotification>.broadcast();
  Stream<MatchNotification> get notificationStream => _notificationController.stream;

  // Getters
  List<MatchNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get pendingMatchCount => _pendingMatchCount;
  bool get ttsEnabled => _ttsEnabled;

  /// Initialize the notification service
  Future<void> initialize() async {
    await _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Set TTS language (AC: 8 - Multi-language support)
  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _tts.setLanguage(languageCode);
  }

  /// Toggle TTS
  void setTtsEnabled(bool enabled) {
    _ttsEnabled = enabled;
    notifyListeners();
  }

  /// Update pending match count for badge (AC: 5.3)
  void updatePendingMatchCount(int count) {
    _pendingMatchCount = count;
    notifyListeners();
  }

  /// Handle incoming FCM notification (AC: 5.1)
  Future<MatchNotification?> handleFcmNotification(Map<String, dynamic> data) async {
    // Parse the notification type
    final typeStr = data['type'] as String?;
    if (typeStr == null) return null;

    MatchNotificationType type;
    switch (typeStr) {
      case 'MATCH_FOUND':
        type = MatchNotificationType.newMatch;
        break;
      case 'MATCH_EXPIRY_REMINDER':
        type = MatchNotificationType.matchExpirySoon;
        break;
      case 'MATCH_EXPIRED':
        type = MatchNotificationType.matchExpired;
        break;
      default:
        return null;
    }

    // Parse match data if available
    Match? match;
    if (data['match'] != null) {
      try {
        match = Match.fromJson(data['match'] as Map<String, dynamic>);
      } catch (_) {}
    }

    // Create notification
    final notification = MatchNotification(
      id: data['notification_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      match: match,
      message: data['message'] as String? ?? _getDefaultMessage(type, match),
      createdAt: DateTime.now(),
    );

    // Add to list and notify
    _notifications.insert(0, notification);
    _notificationController.add(notification);
    notifyListeners();

    // Announce via TTS for new matches (AC: 8)
    if (type == MatchNotificationType.newMatch && _ttsEnabled && match != null) {
      await announceMatch(match);
    }

    return notification;
  }

  String _getDefaultMessage(MatchNotificationType type, Match? match) {
    switch (type) {
      case MatchNotificationType.newMatch:
        if (match != null) {
          return 'Buyer found for your ${match.formattedQuantity} ${match.listing.cropType}!';
        }
        return 'A buyer has matched with your listing!';
      case MatchNotificationType.matchExpirySoon:
        return 'Your match expires in 2 hours. Accept or reject now.';
      case MatchNotificationType.matchExpired:
        return 'Match expired without response.';
      case MatchNotificationType.matchAccepted:
        return 'Match confirmed! Deliver to the assigned drop point.';
      case MatchNotificationType.matchRejected:
        return 'Match declined. Finding new buyers...';
    }
  }

  /// Announce match details via TTS (AC: 8)
  Future<void> announceMatch(Match match) async {
    if (!_ttsEnabled) return;

    final announcement = match.ttsAnnouncement;
    await _tts.speak(announcement);
  }

  /// Stop TTS
  Future<void> stopTts() async {
    await _tts.stop();
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Get deep link route for notification (AC: 5.2)
  String getDeepLinkRoute(MatchNotification notification) {
    if (notification.match != null) {
      return '/match-details';
    }
    return '/matches';
  }

  /// Dispose resources
  @override
  void dispose() {
    _notificationController.close();
    _tts.stop();
    super.dispose();
  }
}

// Singleton instance
final matchNotificationService = MatchNotificationService();
