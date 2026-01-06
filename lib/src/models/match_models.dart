// Match Models - Story 3.5
// Models for buyer match notifications and acceptance flow.

/// Match status for farmer-buyer matches
enum MatchStatus {
  pendingAcceptance,
  accepted,
  rejected,
  expired,
}

extension MatchStatusExtension on MatchStatus {
  String get label {
    switch (this) {
      case MatchStatus.pendingAcceptance:
        return 'Pending';
      case MatchStatus.accepted:
        return 'Accepted';
      case MatchStatus.rejected:
        return 'Rejected';
      case MatchStatus.expired:
        return 'Expired';
    }
  }

  String get apiValue {
    switch (this) {
      case MatchStatus.pendingAcceptance:
        return 'PENDING_ACCEPTANCE';
      case MatchStatus.accepted:
        return 'ACCEPTED';
      case MatchStatus.rejected:
        return 'REJECTED';
      case MatchStatus.expired:
        return 'EXPIRED';
    }
  }

  static MatchStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING_ACCEPTANCE':
        return MatchStatus.pendingAcceptance;
      case 'ACCEPTED':
        return MatchStatus.accepted;
      case 'REJECTED':
        return MatchStatus.rejected;
      case 'EXPIRED':
        return MatchStatus.expired;
      default:
        return MatchStatus.pendingAcceptance;
    }
  }
}

/// Rejection reasons for match decline
enum RejectionReason {
  qualityChanged,
  soldElsewhere,
  changedMind,
  other,
}

extension RejectionReasonExtension on RejectionReason {
  String get label {
    switch (this) {
      case RejectionReason.qualityChanged:
        return 'Quality changed';
      case RejectionReason.soldElsewhere:
        return 'Sold elsewhere';
      case RejectionReason.changedMind:
        return 'Changed my mind';
      case RejectionReason.other:
        return 'Other reason';
    }
  }

  String get apiValue {
    switch (this) {
      case RejectionReason.qualityChanged:
        return 'QUALITY_CHANGED';
      case RejectionReason.soldElsewhere:
        return 'SOLD_ELSEWHERE';
      case RejectionReason.changedMind:
        return 'CHANGED_MIND';
      case RejectionReason.other:
        return 'OTHER';
    }
  }
}

/// Buyer information (anonymized for farmer view)
class Buyer {
  final String? id;
  final String businessType; // Restaurant, Retailer, Hotel, etc.
  final String city;
  final String? area; // Koramangala, Indiranagar, etc.

  const Buyer({
    this.id,
    required this.businessType,
    required this.city,
    this.area,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] as String?,
      businessType: json['business_type'] as String? ?? 'Buyer',
      city: json['city'] as String? ?? '',
      area: json['area'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'business_type': businessType,
        'city': city,
        if (area != null) 'area': area,
      };

  /// Display format: "Restaurant in Bangalore"
  String get displayName {
    if (area != null) {
      return '$businessType in $area, $city';
    }
    return '$businessType in $city';
  }

  /// Create mock buyer for development
  factory Buyer.mock() {
    return const Buyer(
      id: 'buyer-001',
      businessType: 'Restaurant',
      city: 'Bangalore',
      area: 'Koramangala',
    );
  }
}

/// Listing summary for match context
class MatchListing {
  final String id;
  final String cropType;
  final String cropEmoji;
  final double quantityKg;
  final String? photoUrl;

  const MatchListing({
    required this.id,
    required this.cropType,
    required this.cropEmoji,
    required this.quantityKg,
    this.photoUrl,
  });

  factory MatchListing.fromJson(Map<String, dynamic> json) {
    return MatchListing(
      id: json['id'] as String? ?? '',
      cropType: json['crop_type'] as String? ?? '',
      cropEmoji: json['crop_emoji'] as String? ?? '🌾',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_type': cropType,
        'crop_emoji': cropEmoji,
        'quantity_kg': quantityKg,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

  /// Create mock listing for development
  factory MatchListing.mock() {
    return const MatchListing(
      id: 'listing-001',
      cropType: 'Tomatoes',
      cropEmoji: '🍅',
      quantityKg: 50.0,
      photoUrl: null,
    );
  }
}

/// Buyer match for farmer's listing
class Match {
  final String id;
  final MatchListing listing;
  final Buyer buyer;
  final double quantityRequested;
  final double pricePerKg;
  final double totalAmount;
  final DateTime expiresAt;
  final MatchStatus status;
  final String? rejectionReason;
  final String? deliveryDate; // "Tomorrow afternoon"
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.listing,
    required this.buyer,
    required this.quantityRequested,
    required this.pricePerKg,
    required this.totalAmount,
    required this.expiresAt,
    required this.status,
    this.rejectionReason,
    this.deliveryDate,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String? ?? '',
      listing: MatchListing.fromJson(json['listing'] as Map<String, dynamic>? ?? {}),
      buyer: Buyer.fromJson(json['buyer'] as Map<String, dynamic>? ?? {}),
      quantityRequested: (json['quantity_requested'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ?? 
                 DateTime.now().add(const Duration(hours: 24)),
      status: MatchStatusExtension.fromString(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing': listing.toJson(),
        'buyer': buyer.toJson(),
        'quantity_requested': quantityRequested,
        'price_per_kg': pricePerKg,
        'total_amount': totalAmount,
        'expires_at': expiresAt.toIso8601String(),
        'status': status.apiValue,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (deliveryDate != null) 'delivery_date': deliveryDate,
        'created_at': createdAt.toIso8601String(),
      };

  // ============================================
  // Computed Properties
  // ============================================

  /// True if buyer requested less than full listing quantity
  bool get isPartial => quantityRequested < listing.quantityKg;

  /// Remaining quantity if partial match accepted
  double get remainingQuantity => listing.quantityKg - quantityRequested;

  /// True if match has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// True if match can still be acted upon
  bool get isPending => status == MatchStatus.pendingAcceptance && !isExpired;

  /// Time remaining until expiry
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  /// Format countdown as "2h 45m" or "45m"
  String get expiryCountdownText {
    final diff = timeUntilExpiry;
    if (diff.isNegative) return 'Expired';
    
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// True if expiry is within 2 hours (show warning)
  bool get isExpiryWarning => timeUntilExpiry.inHours < 2 && !isExpired;

  /// True if expiry is within 30 minutes (show urgent)
  bool get isExpiryUrgent => timeUntilExpiry.inMinutes < 30 && !isExpired;

  /// Format price as "₹1,800"
  String get formattedTotal {
    // Simple Indian number formatting
    final amount = totalAmount.round();
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹$amount';
  }

  /// Format price per kg as "₹36/kg"
  String get formattedPricePerKg => '₹${pricePerKg.toStringAsFixed(0)}/kg';

  /// Format quantity as "50 kg"
  String get formattedQuantity => '${quantityRequested.toStringAsFixed(0)} kg';

  /// Partial match display: "30 kg of your 50 kg"
  String get partialMatchText {
    if (!isPartial) return formattedQuantity;
    return '${quantityRequested.toStringAsFixed(0)} kg of your ${listing.quantityKg.toStringAsFixed(0)} kg';
  }

  /// TTS announcement text for voice confirmation
  String get ttsAnnouncement {
    return 'A buyer wants your ${listing.cropType} for $formattedTotal. '
           'Quantity: $formattedQuantity. '
           'Accept or reject?';
  }

  // ============================================
  // Factory Methods
  // ============================================

  /// Create mock match for development
  factory Match.mock({bool isPartial = false}) {
    return Match(
      id: 'match-001',
      listing: MatchListing.mock(),
      buyer: Buyer.mock(),
      quantityRequested: isPartial ? 30.0 : 50.0,
      pricePerKg: 36.0,
      totalAmount: isPartial ? 1080.0 : 1800.0,
      expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      status: MatchStatus.pendingAcceptance,
      deliveryDate: 'Tomorrow afternoon',
      createdAt: DateTime.now(),
    );
  }

  /// Create expired mock for testing
  factory Match.mockExpired() {
    return Match(
      id: 'match-expired',
      listing: MatchListing.mock(),
      buyer: Buyer.mock(),
      quantityRequested: 50.0,
      pricePerKg: 36.0,
      totalAmount: 1800.0,
      expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: MatchStatus.expired,
      deliveryDate: 'Yesterday',
      createdAt: DateTime.now().subtract(const Duration(hours: 25)),
    );
  }
}

/// Response from accept match API
class AcceptMatchResponse {
  final bool success;
  final String? orderId;
  final String? message;
  final Map<String, dynamic>? dropPoint;

  const AcceptMatchResponse({
    required this.success,
    this.orderId,
    this.message,
    this.dropPoint,
  });

  factory AcceptMatchResponse.fromJson(Map<String, dynamic> json) {
    return AcceptMatchResponse(
      success: json['success'] as bool? ?? false,
      orderId: json['order_id'] as String?,
      message: json['message'] as String?,
      dropPoint: json['drop_point'] as Map<String, dynamic>?,
    );
  }
}

/// Response from reject match API
class RejectMatchResponse {
  final bool success;
  final String? listingStatus;

  const RejectMatchResponse({
    required this.success,
    this.listingStatus,
  });

  factory RejectMatchResponse.fromJson(Map<String, dynamic> json) {
    return RejectMatchResponse(
      success: json['success'] as bool? ?? false,
      listingStatus: json['listing_status'] as String?,
    );
  }
}
