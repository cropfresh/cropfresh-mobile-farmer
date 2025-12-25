import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/notification_widgets.dart';
import 'package:cropfresh_mobile_farmer/src/models/notification_models.dart';

void main() {
  group('NotificationCard', () {
    testWidgets('displays unread notification correctly', (tester) async {
      final notification = AppNotification(
        id: 'test-1',
        type: NotificationType.orderMatched,
        title: 'Buyer Found!',
        body: 'Accept match for 50kg Tomato',
        createdAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notification,
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Buyer Found!'), findsOneWidget);
      
      // Verify body is displayed
      expect(find.text('Accept match for 50kg Tomato'), findsOneWidget);
      
      // Verify card exists
      expect(find.byType(NotificationCard), findsOneWidget);
    });

    testWidgets('displays read notification correctly', (tester) async {
      final notification = AppNotification(
        id: 'test-2',
        type: NotificationType.paymentReceived,
        title: 'Payment Received',
        body: '₹5,000 credited',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notification,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Payment Received'), findsOneWidget);
      expect(find.text('₹5,000 credited'), findsOneWidget);
    });

    testWidgets('shows correct icon for hauler notification type', (tester) async {
      final notification = AppNotification(
        id: 'test-3',
        type: NotificationType.haulerEnRoute,
        title: 'Hauler Coming',
        body: 'ETA 15 minutes',
        createdAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notification,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify truck icon is displayed for hauler notification
      expect(find.byIcon(Icons.local_shipping), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final notification = AppNotification(
        id: 'test-4',
        type: NotificationType.orderMatched,
        title: 'Test',
        body: 'Test body',
        createdAt: DateTime.now(),
        isRead: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notification,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NotificationCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('NotificationBellBadge', () {
    testWidgets('shows badge when count > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBellBadge(
              unreadCount: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify bell exists
      expect(find.byType(NotificationBellBadge), findsOneWidget);
      
      // Verify badge count
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('hides badge when count is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBellBadge(
              unreadCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify bell exists
      expect(find.byType(NotificationBellBadge), findsOneWidget);
      
      // Verify no count text (badge hidden)
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows 99+ for large counts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBellBadge(
              unreadCount: 150,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify badge shows 99+
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationBellBadge(
              unreadCount: 3,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NotificationBellBadge));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('NotificationEmptyState', () {
    testWidgets('displays empty state illustration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationEmptyState(),
          ),
        ),
      );

      // Should show empty state - check for widget existing
      expect(find.byType(NotificationEmptyState), findsOneWidget);
    });
  });

  group('AppNotification model', () {
    test('creates notification from JSON', () {
      final json = {
        'id': 'notif-1',
        'type': 'ORDER_MATCHED',
        'title': 'Buyer Found',
        'body': 'Accept match',
        'is_read': false,
        'created_at': '2025-12-25T10:00:00Z',
        'deeplink': '/match/123',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 'notif-1');
      expect(notification.type, NotificationType.orderMatched);
      expect(notification.title, 'Buyer Found');
      expect(notification.isRead, false);
    });

    test('generates TTS announcement correctly', () {
      final notification = AppNotification(
        id: 'n1',
        type: NotificationType.paymentReceived,
        title: 'Payment Received',
        body: 'Rs 5000 for Tomato',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final tts = notification.ttsAnnouncement;
      
      expect(tts, contains('Payment Received'));
      expect(tts, contains('Rs 5000'));
    });

    test('formats relative time correctly for just now', () {
      final justNow = AppNotification(
        id: 'n1',
        type: NotificationType.orderMatched,
        title: 'Test',
        body: 'Test',
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        isRead: false,
      );
      expect(justNow.relativeTime.toLowerCase(), contains('now'));
    });

    test('formats relative time correctly for minutes ago', () {
      final minutesAgo = AppNotification(
        id: 'n2',
        type: NotificationType.orderMatched,
        title: 'Test',
        body: 'Test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      );
      expect(minutesAgo.relativeTime, contains('5'));
    });

    test('serializes to JSON correctly', () {
      final notification = AppNotification(
        id: 'n1',
        type: NotificationType.paymentReceived,
        title: 'Payment',
        body: 'Test body',
        createdAt: DateTime(2025, 12, 25, 10, 0),
        isRead: true,
      );

      final json = notification.toJson();

      expect(json['id'], 'n1');
      expect(json['type'], 'PAYMENT_RECEIVED');
      expect(json['is_read'], true);
    });

    test('copyWith works correctly', () {
      final original = AppNotification(
        id: 'n1',
        type: NotificationType.orderMatched,
        title: 'Original',
        body: 'Original body',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final copied = original.copyWith(isRead: true, title: 'Updated');

      expect(copied.id, 'n1');
      expect(copied.title, 'Updated');
      expect(copied.isRead, true);
      expect(original.isRead, false);
    });
  });

  group('NotificationPreferences model', () {
    test('creates preferences from JSON', () {
      final json = {
        'sms_enabled': true,
        'push_enabled': false,
        'quiet_hours_enabled': true,
        'quiet_hours_start': '22:00',
        'quiet_hours_end': '06:00',
        'notification_level': 'critical',
        'order_updates': true,
        'payment_alerts': true,
        'educational_content': false,
      };

      final prefs = NotificationPreferences.fromJson(json);

      expect(prefs.smsEnabled, true);
      expect(prefs.pushEnabled, false);
      expect(prefs.level, NotificationLevel.criticalOnly);
      expect(prefs.educationalContent, false);
    });

    test('serializes preferences to JSON', () {
      const prefs = NotificationPreferences(
        smsEnabled: true,
        pushEnabled: true,
        quietHoursEnabled: true,
        quietHoursStart: TimeOfDay(hour: 21, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
        level: NotificationLevel.all,
        orderUpdates: true,
        paymentAlerts: true,
        educationalContent: true,
      );

      final json = prefs.toJson();

      expect(json['sms_enabled'], true);
      expect(json['quiet_hours_start'], '21:00');
      expect(json['notification_level'], 'all');
    });

    test('default preferences are correct', () {
      const prefs = NotificationPreferences();

      expect(prefs.smsEnabled, true);
      expect(prefs.pushEnabled, true);
      expect(prefs.quietHoursEnabled, true);
      expect(prefs.level, NotificationLevel.all);
    });

    test('copyWith works correctly', () {
      const original = NotificationPreferences();
      final copied = original.copyWith(smsEnabled: false, level: NotificationLevel.mute);

      expect(copied.smsEnabled, false);
      expect(copied.level, NotificationLevel.mute);
      expect(original.smsEnabled, true);
    });

    test('quiet hours display format is correct', () {
      const prefs = NotificationPreferences(
        quietHoursStart: TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd: TimeOfDay(hour: 6, minute: 0),
      );

      expect(prefs.quietHoursDisplay, contains('10:00 PM'));
      expect(prefs.quietHoursDisplay, contains('6:00 AM'));
    });
  });

  group('NotificationsResponse model', () {
    test('creates response from JSON', () {
      final json = {
        'notifications': [
          {
            'id': 'n1',
            'type': 'ORDER_MATCHED',
            'title': 'Test',
            'body': 'Body',
            'is_read': false,
            'created_at': '2025-12-25T10:00:00Z',
          }
        ],
        'unread_count': 1,
        'pagination': {
          'page': 1,
          'limit': 20,
          'total': 1,
          'has_more': false,
        },
      };

      final response = NotificationsResponse.fromJson(json);

      expect(response.notifications.length, 1);
      expect(response.unreadCount, 1);
      expect(response.page, 1);
      expect(response.hasMore, false);
    });

    test('empty response works correctly', () {
      final response = NotificationsResponse.empty();

      expect(response.isEmpty, true);
      expect(response.unreadCount, 0);
    });

    test('mock response generates correct data', () {
      final response = NotificationsResponse.mock(count: 5, unread: 2);

      expect(response.notifications.length, 5);
      expect(response.unreadCount, 2);
    });

    test('TTS announcement for no unread', () {
      final noUnread = NotificationsResponse.mock(count: 5, unread: 0);
      expect(noUnread.ttsAnnouncement, contains('no unread'));
    });

    test('TTS announcement for one unread', () {
      final oneUnread = NotificationsResponse.mock(count: 5, unread: 1);
      expect(oneUnread.ttsAnnouncement, contains('1 unread'));
    });

    test('TTS announcement for many unread', () {
      final manyUnread = NotificationsResponse.mock(count: 5, unread: 3);
      expect(manyUnread.ttsAnnouncement, contains('3 unread'));
    });
  });

  group('NotificationType extension', () {
    test('all types have icons', () {
      for (final type in NotificationType.values) {
        expect(type.icon, isA<IconData>());
      }
    });

    test('all types have colors', () {
      for (final type in NotificationType.values) {
        expect(type.color, isA<Color>());
      }
    });

    test('critical types are identified correctly', () {
      expect(NotificationType.orderMatched.isCritical, true);
      expect(NotificationType.paymentReceived.isCritical, true);
      expect(NotificationType.matchExpiring.isCritical, true);
      expect(NotificationType.haulerEnRoute.isCritical, false);
      expect(NotificationType.educationalContent.isCritical, false);
    });

    test('fromString parses correctly', () {
      expect(NotificationTypeExtension.fromString('ORDER_MATCHED'), NotificationType.orderMatched);
      expect(NotificationTypeExtension.fromString('PAYMENT_RECEIVED'), NotificationType.paymentReceived);
      expect(NotificationTypeExtension.fromString('unknown'), NotificationType.educationalContent);
    });
  });
}
