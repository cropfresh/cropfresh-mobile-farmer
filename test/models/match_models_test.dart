// Match Model Tests - Story 3.5 (Task 9.6)
// 
// Tests for match data models and serialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/models/match_models.dart';

void main() {
  // ============================================================================
  // MatchStatus Tests
  // ============================================================================

  group('MatchStatus', () {
    test('enum labels are correct', () {
      expect(MatchStatus.pendingAcceptance.label, equals('Pending'));
      expect(MatchStatus.accepted.label, equals('Accepted'));
      expect(MatchStatus.rejected.label, equals('Rejected'));
      expect(MatchStatus.expired.label, equals('Expired'));
    });

    test('fromString parses API values correctly', () {
      expect(
        MatchStatusExtension.fromString('PENDING_ACCEPTANCE'),
        equals(MatchStatus.pendingAcceptance),
      );
      expect(
        MatchStatusExtension.fromString('ACCEPTED'),
        equals(MatchStatus.accepted),
      );
      expect(
        MatchStatusExtension.fromString('REJECTED'),
        equals(MatchStatus.rejected),
      );
      expect(
        MatchStatusExtension.fromString('EXPIRED'),
        equals(MatchStatus.expired),
      );
    });

    test('fromString handles null and unknown values', () {
      expect(
        MatchStatusExtension.fromString(null),
        equals(MatchStatus.pendingAcceptance),
      );
      expect(
        MatchStatusExtension.fromString('UNKNOWN'),
        equals(MatchStatus.pendingAcceptance),
      );
    });
  });

  // ============================================================================
  // RejectionReason Tests
  // ============================================================================

  group('RejectionReason', () {
    test('enum labels are correct', () {
      expect(RejectionReason.qualityChanged.label, equals('Quality changed'));
      expect(RejectionReason.soldElsewhere.label, equals('Sold elsewhere'));
      expect(RejectionReason.changedMind.label, equals('Changed my mind'));
      expect(RejectionReason.other.label, equals('Other reason'));
    });

    test('apiValue returns correct strings', () {
      expect(RejectionReason.qualityChanged.apiValue, equals('QUALITY_CHANGED'));
      expect(RejectionReason.soldElsewhere.apiValue, equals('SOLD_ELSEWHERE'));
    });
  });

  // ============================================================================
  // Buyer Tests
  // ============================================================================

  group('Buyer', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'buyer-123',
        'business_type': 'Restaurant',
        'city': 'Bangalore',
        'area': 'Koramangala',
      };

      final buyer = Buyer.fromJson(json);

      expect(buyer.id, equals('buyer-123'));
      expect(buyer.businessType, equals('Restaurant'));
      expect(buyer.city, equals('Bangalore'));
      expect(buyer.area, equals('Koramangala'));
    });

    test('toJson serializes all fields', () {
      const buyer = Buyer(
        id: 'buyer-123',
        businessType: 'Restaurant',
        city: 'Bangalore',
        area: 'Koramangala',
      );

      final json = buyer.toJson();

      expect(json['id'], equals('buyer-123'));
      expect(json['business_type'], equals('Restaurant'));
      expect(json['city'], equals('Bangalore'));
      expect(json['area'], equals('Koramangala'));
    });

    test('displayName formats correctly with area', () {
      const buyer = Buyer(
        businessType: 'Restaurant',
        city: 'Bangalore',
        area: 'Koramangala',
      );

      expect(buyer.displayName, equals('Restaurant in Koramangala, Bangalore'));
    });

    test('displayName formats correctly without area', () {
      const buyer = Buyer(
        businessType: 'Retailer',
        city: 'Mumbai',
      );

      expect(buyer.displayName, equals('Retailer in Mumbai'));
    });
  });

  // ============================================================================
  // MatchListing Tests
  // ============================================================================

  group('MatchListing', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'listing-123',
        'crop_type': 'Tomatoes',
        'crop_emoji': '🍅',
        'quantity_kg': 50.0,
        'photo_url': 'https://example.com/photo.jpg',
      };

      final listing = MatchListing.fromJson(json);

      expect(listing.id, equals('listing-123'));
      expect(listing.cropType, equals('Tomatoes'));
      expect(listing.cropEmoji, equals('🍅'));
      expect(listing.quantityKg, equals(50.0));
      expect(listing.photoUrl, equals('https://example.com/photo.jpg'));
    });

    test('toJson serializes all fields', () {
      const listing = MatchListing(
        id: 'listing-123',
        cropType: 'Tomatoes',
        cropEmoji: '🍅',
        quantityKg: 50.0,
        photoUrl: 'https://example.com/photo.jpg',
      );

      final json = listing.toJson();

      expect(json['id'], equals('listing-123'));
      expect(json['crop_type'], equals('Tomatoes'));
      expect(json['crop_emoji'], equals('🍅'));
      expect(json['quantity_kg'], equals(50.0));
      expect(json['photo_url'], equals('https://example.com/photo.jpg'));
    });
  });

  // ============================================================================
  // Match Tests
  // ============================================================================

  group('Match', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'match-123',
        'listing': {
          'id': 'listing-001',
          'crop_type': 'Tomatoes',
          'crop_emoji': '🍅',
          'quantity_kg': 50.0,
        },
        'buyer': {
          'business_type': 'Restaurant',
          'city': 'Bangalore',
        },
        'quantity_requested': 30.0,
        'price_per_kg': 36.0,
        'total_amount': 1080.0,
        'expires_at': '2025-12-24T07:00:00+05:30',
        'status': 'PENDING_ACCEPTANCE',
        'delivery_date': 'Tomorrow afternoon',
        'created_at': '2025-12-22T10:00:00+05:30',
      };

      final match = Match.fromJson(json);

      expect(match.id, equals('match-123'));
      expect(match.listing.cropType, equals('Tomatoes'));
      expect(match.buyer.businessType, equals('Restaurant'));
      expect(match.quantityRequested, equals(30.0));
      expect(match.pricePerKg, equals(36.0));
      expect(match.totalAmount, equals(1080.0));
      expect(match.status, equals(MatchStatus.pendingAcceptance));
      expect(match.deliveryDate, equals('Tomorrow afternoon'));
    });

    test('toJson serializes all fields', () {
      final match = Match.mock();
      final json = match.toJson();

      expect(json['id'], isNotEmpty);
      expect(json['listing'], isA<Map>());
      expect(json['buyer'], isA<Map>());
      expect(json['quantity_requested'], isA<double>());
      expect(json['total_amount'], isA<double>());
      expect(json['expires_at'], isA<String>());
      expect(json['status'], equals('PENDING_ACCEPTANCE'));
    });

    test('isPartial returns true when quantity < listing', () {
      final match = Match.mock(isPartial: true);
      expect(match.isPartial, isTrue);
      expect(match.quantityRequested, lessThan(match.listing.quantityKg));
    });

    test('isPartial returns false for full match', () {
      final match = Match.mock(isPartial: false);
      expect(match.isPartial, isFalse);
    });

    test('isExpired returns true after expiry date', () {
      final match = Match.mockExpired();
      expect(match.isExpired, isTrue);
    });

    test('isExpired returns false before expiry date', () {
      final match = Match.mock();
      expect(match.isExpired, isFalse);
    });

    test('remainingQuantity calculates correctly', () {
      final match = Match.mock(isPartial: true);
      expect(
        match.remainingQuantity,
        equals(match.listing.quantityKg - match.quantityRequested),
      );
    });

    test('formattedTotal returns ₹ formatted string', () {
      final match = Match.mock();
      expect(match.formattedTotal, contains('₹'));
    });

    test('formattedPricePerKg includes /kg suffix', () {
      final match = Match.mock();
      expect(match.formattedPricePerKg, contains('/kg'));
    });

    test('partialMatchText formats correctly for partial', () {
      final match = Match.mock(isPartial: true);
      expect(match.partialMatchText, contains('of your'));
    });

    test('partialMatchText returns simple quantity for full match', () {
      final match = Match.mock(isPartial: false);
      expect(match.partialMatchText, isNot(contains('of your')));
    });

    test('ttsAnnouncement contains required information', () {
      final match = Match.mock();
      final announcement = match.ttsAnnouncement;
      
      expect(announcement, contains(match.listing.cropType));
      expect(announcement, contains('Accept or reject'));
    });

    test('isPending returns true for pending non-expired match', () {
      final match = Match.mock();
      expect(match.isPending, isTrue);
    });

    test('isPending returns false for expired match', () {
      final match = Match.mockExpired();
      expect(match.isPending, isFalse);
    });
  });

  // ============================================================================
  // AcceptMatchResponse Tests
  // ============================================================================

  group('AcceptMatchResponse', () {
    test('fromJson parses success response', () {
      final json = {
        'success': true,
        'order_id': 'order-123',
        'message': 'Match accepted!',
        'drop_point': {'name': 'Kolar Drop Point'},
      };

      final response = AcceptMatchResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.orderId, equals('order-123'));
      expect(response.message, equals('Match accepted!'));
      expect(response.dropPoint, isNotNull);
    });
  });

  // ============================================================================
  // RejectMatchResponse Tests
  // ============================================================================

  group('RejectMatchResponse', () {
    test('fromJson parses success response', () {
      final json = {
        'success': true,
        'listing_status': 'ACTIVE',
      };

      final response = RejectMatchResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.listingStatus, equals('ACTIVE'));
    });
  });
}
