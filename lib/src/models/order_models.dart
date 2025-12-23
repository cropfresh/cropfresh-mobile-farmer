// Order Models - Story 3.6
// Models for order status tracking and timeline display.

/// Order status for farmer's order tracking (7 stages)
enum OrderStatus {
  listed,
  matched,
  pickupScheduled,
  atDropPoint,
  inTransit,
  delivered,
  paid,
}

extension OrderStatusExtension on OrderStatus {
  /// Step number in timeline (1-7)
  int get step {
    switch (this) {
      case OrderStatus.listed:
        return 1;
      case OrderStatus.matched:
        return 2;
      case OrderStatus.pickupScheduled:
        return 3;
      case OrderStatus.atDropPoint:
        return 4;
      case OrderStatus.inTransit:
        return 5;
      case OrderStatus.delivered:
        return 6;
      case OrderStatus.paid:
        return 7;
    }
  }

  /// Display label for timeline
  String get label {
    switch (this) {
      case OrderStatus.listed:
        return 'Listed';
      case OrderStatus.matched:
        return 'Matched';
      case OrderStatus.pickupScheduled:
        return 'Pickup Scheduled';
      case OrderStatus.atDropPoint:
        return 'At Drop Point';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.paid:
        return 'Payment Received';
    }
  }

  /// Description for timeline card
  String get description {
    switch (this) {
      case OrderStatus.listed:
        return 'Your produce listed';
      case OrderStatus.matched:
        return 'Buyer found';
      case OrderStatus.pickupScheduled:
        return 'Deliver to drop point';
      case OrderStatus.atDropPoint:
        return 'Awaiting hauler pickup';
      case OrderStatus.inTransit:
        return 'Hauler en route to buyer';
      case OrderStatus.delivered:
        return 'Buyer confirms delivery';
      case OrderStatus.paid:
        return 'Payment received';
    }
  }

  /// Icon for timeline (Material Icons name)
  String get iconName {
    switch (this) {
      case OrderStatus.listed:
        return 'inventory_2';
      case OrderStatus.matched:
        return 'handshake';
      case OrderStatus.pickupScheduled:
        return 'schedule';
      case OrderStatus.atDropPoint:
        return 'location_on';
      case OrderStatus.inTransit:
        return 'local_shipping';
      case OrderStatus.delivered:
        return 'check_circle';
      case OrderStatus.paid:
        return 'payments';
    }
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.listed:
        return 'LISTED';
      case OrderStatus.matched:
        return 'MATCHED';
      case OrderStatus.pickupScheduled:
        return 'PICKUP_SCHEDULED';
      case OrderStatus.atDropPoint:
        return 'AT_DROP_POINT';
      case OrderStatus.inTransit:
        return 'IN_TRANSIT';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.paid:
        return 'PAID';
    }
  }

  static OrderStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'LISTED':
        return OrderStatus.listed;
      case 'MATCHED':
        return OrderStatus.matched;
      case 'PICKUP_SCHEDULED':
        return OrderStatus.pickupScheduled;
      case 'AT_DROP_POINT':
        return OrderStatus.atDropPoint;
      case 'IN_TRANSIT':
        return OrderStatus.inTransit;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'PAID':
        return OrderStatus.paid;
      default:
        return OrderStatus.listed;
    }
  }
}

/// Filter type for order list
enum OrderFilter {
  active,
  completed,
  all,
}

extension OrderFilterExtension on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.active:
        return 'Active';
      case OrderFilter.completed:
        return 'Completed';
      case OrderFilter.all:
        return 'All';
    }
  }
}

/// Timeline event for status history
class TimelineEvent {
  final int step;
  final OrderStatus status;
  final String label;
  final bool completed;
  final bool active;
  final DateTime? timestamp;
  final String? note;

  const TimelineEvent({
    required this.step,
    required this.status,
    required this.label,
    this.completed = false,
    this.active = false,
    this.timestamp,
    this.note,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final status = OrderStatusExtension.fromString(json['status'] as String?);
    return TimelineEvent(
      step: json['step'] as int? ?? status.step,
      status: status,
      label: json['label'] as String? ?? status.label,
      completed: json['completed'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'status': status.apiValue,
        'label': label,
        'completed': completed,
        'active': active,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (note != null) 'note': note,
      };

  /// Format timestamp as "Dec 22, 3:45 PM"
  String? get formattedTimestamp {
    if (timestamp == null) return null;
    final dt = timestamp!;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}

/// Hauler information (for In Transit state)
class Hauler {
  final String id;
  final String name;
  final String phone;
  final String? vehicleType;
  final String? vehicleNumber;

  const Hauler({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleType,
    this.vehicleNumber,
  });

  factory Hauler.fromJson(Map<String, dynamic> json) {
    return Hauler(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Hauler',
      phone: json['phone'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
      };

  /// Display format: "Tempo - KA01AB1234"
  String get vehicleDisplay {
    if (vehicleType != null && vehicleNumber != null) {
      return '$vehicleType - $vehicleNumber';
    }
    return vehicleType ?? vehicleNumber ?? 'Vehicle';
  }

  factory Hauler.mock() {
    return const Hauler(
      id: 'hauler-001',
      name: 'Raju Kumar',
      phone: '+919876543210',
      vehicleType: 'Tempo',
      vehicleNumber: 'KA01AB1234',
    );
  }
}

/// Order listing summary (crop info)
class OrderListing {
  final String id;
  final String cropType;
  final String cropEmoji;
  final double quantityKg;
  final String? photoUrl;

  const OrderListing({
    required this.id,
    required this.cropType,
    required this.cropEmoji,
    required this.quantityKg,
    this.photoUrl,
  });

  factory OrderListing.fromJson(Map<String, dynamic> json) {
    return OrderListing(
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

  /// Format quantity as "50 kg"
  String get formattedQuantity => '${quantityKg.toStringAsFixed(0)} kg';

  factory OrderListing.mock() {
    return const OrderListing(
      id: 'listing-001',
      cropType: 'Tomatoes',
      cropEmoji: '🍅',
      quantityKg: 50.0,
      photoUrl: null,
    );
  }
}

/// Buyer summary (anonymized for farmer view)
class OrderBuyer {
  final String? id;
  final String businessType;
  final String city;
  final String? area;

  const OrderBuyer({
    this.id,
    required this.businessType,
    required this.city,
    this.area,
  });

  factory OrderBuyer.fromJson(Map<String, dynamic> json) {
    return OrderBuyer(
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

  factory OrderBuyer.mock() {
    return const OrderBuyer(
      id: 'buyer-001',
      businessType: 'Restaurant',
      city: 'Bangalore',
      area: 'Koramangala',
    );
  }
}

/// Main Order model for farmer tracking
class Order {
  final String id;
  final OrderListing listing;
  final OrderBuyer buyer;
  final OrderStatus status;
  final int currentStep;
  final int totalSteps;
  final double totalAmount;
  final DateTime? eta;
  final int? delayMinutes;
  final String? delayReason;
  final Hauler? hauler;
  final List<TimelineEvent> timeline;
  final String? upiTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.listing,
    required this.buyer,
    required this.status,
    this.currentStep = 1,
    this.totalSteps = 7,
    required this.totalAmount,
    this.eta,
    this.delayMinutes,
    this.delayReason,
    this.hauler,
    this.timeline = const [],
    this.upiTransactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      listing: OrderListing.fromJson(
          json['listing'] as Map<String, dynamic>? ?? {}),
      buyer:
          OrderBuyer.fromJson(json['buyer'] as Map<String, dynamic>? ?? {}),
      status: OrderStatusExtension.fromString(json['status'] as String?),
      currentStep: json['current_step'] as int? ?? 1,
      totalSteps: json['total_steps'] as int? ?? 7,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      eta: DateTime.tryParse(json['eta'] as String? ?? ''),
      delayMinutes: json['delay_minutes'] as int?,
      delayReason: json['delay_reason'] as String?,
      hauler: json['hauler'] != null
          ? Hauler.fromJson(json['hauler'] as Map<String, dynamic>)
          : null,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upiTransactionId: json['upi_transaction_id'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listing': listing.toJson(),
        'buyer': buyer.toJson(),
        'status': status.apiValue,
        'current_step': currentStep,
        'total_steps': totalSteps,
        'total_amount': totalAmount,
        if (eta != null) 'eta': eta!.toIso8601String(),
        if (delayMinutes != null) 'delay_minutes': delayMinutes,
        if (delayReason != null) 'delay_reason': delayReason,
        if (hauler != null) 'hauler': hauler!.toJson(),
        'timeline': timeline.map((e) => e.toJson()).toList(),
        if (upiTransactionId != null) 'upi_transaction_id': upiTransactionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  // ============================================
  // Computed Properties
  // ============================================

  /// True if order is still active (not paid)
  bool get isActive => status != OrderStatus.paid;

  /// True if order is completed (paid)
  bool get isCompleted => status == OrderStatus.paid;

  /// True if order has a delay
  bool get hasDelay => delayMinutes != null && delayMinutes! > 0;

  /// Progress percentage (0.0 - 1.0)
  double get progress => currentStep / totalSteps;

  /// Format amount as "₹1,800"
  String get formattedTotal {
    final amount = totalAmount.round();
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹$amount';
  }

  /// Format amount with exact value "₹1,800"
  String get formattedTotalExact {
    return '₹${totalAmount.round()}';
  }

  /// Format ETA as "Today 3:00 PM"
  String? get formattedEta {
    if (eta == null) return null;
    final now = DateTime.now();
    final dt = eta!;
    
    String dayPrefix;
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      dayPrefix = 'Today';
    } else if (dt.day == now.day + 1 && dt.month == now.month && dt.year == now.year) {
      dayPrefix = 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dayPrefix = '${months[dt.month - 1]} ${dt.day}';
    }
    
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayPrefix $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  /// Delay display: "+30 min delay"
  String? get delayDisplay {
    if (!hasDelay) return null;
    return '+$delayMinutes min delay';
  }

  /// Status badge color (for UI)
  String get statusColorKey {
    switch (status) {
      case OrderStatus.listed:
      case OrderStatus.matched:
      case OrderStatus.pickupScheduled:
      case OrderStatus.atDropPoint:
        return 'primary';
      case OrderStatus.inTransit:
        return 'secondary';
      case OrderStatus.delivered:
      case OrderStatus.paid:
        return 'success';
    }
  }

  /// TTS announcement text for voice status
  String get ttsAnnouncement {
    String message = 'Your ${listing.cropType} order is ${status.label}.';
    
    switch (status) {
      case OrderStatus.listed:
        message += ' Waiting for a buyer.';
        break;
      case OrderStatus.matched:
        message += ' ${buyer.displayName} is interested.';
        break;
      case OrderStatus.pickupScheduled:
        message += ' Deliver to drop point by tomorrow morning.';
        break;
      case OrderStatus.atDropPoint:
        message += ' Waiting for hauler pickup.';
        break;
      case OrderStatus.inTransit:
        if (formattedEta != null) {
          message += ' Hauler will deliver by $formattedEta.';
        } else {
          message += ' Hauler is on the way.';
        }
        break;
      case OrderStatus.delivered:
        message += ' Buyer has received your produce.';
        break;
      case OrderStatus.paid:
        message += ' $formattedTotal paid to your UPI.';
        break;
    }
    
    return message;
  }

  // ============================================
  // Factory Methods
  // ============================================

  /// Create mock order for development
  factory Order.mock({OrderStatus status = OrderStatus.inTransit}) {
    return Order(
      id: 'order-001',
      listing: OrderListing.mock(),
      buyer: OrderBuyer.mock(),
      status: status,
      currentStep: status.step,
      totalSteps: 7,
      totalAmount: 1800.0,
      eta: DateTime.now().add(const Duration(hours: 3)),
      delayMinutes: status == OrderStatus.inTransit ? 15 : null,
      delayReason: status == OrderStatus.inTransit ? 'Traffic' : null,
      hauler: status == OrderStatus.inTransit ? Hauler.mock() : null,
      timeline: _generateMockTimeline(status),
      upiTransactionId: status == OrderStatus.paid ? 'UPI123456789' : null,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  /// Create mock active order
  factory Order.mockActive() => Order.mock(status: OrderStatus.inTransit);

  /// Create mock completed order
  factory Order.mockCompleted() => Order.mock(status: OrderStatus.paid);

  /// Generate mock timeline up to current status
  static List<TimelineEvent> _generateMockTimeline(OrderStatus currentStatus) {
    final List<TimelineEvent> timeline = [];
    final now = DateTime.now();
    
    for (final status in OrderStatus.values) {
      final isCompleted = status.step < currentStatus.step;
      final isActive = status == currentStatus;
      
      timeline.add(TimelineEvent(
        step: status.step,
        status: status,
        label: status.label,
        completed: isCompleted,
        active: isActive,
        timestamp: isCompleted || isActive
            ? now.subtract(Duration(hours: (7 - status.step) * 2))
            : null,
      ));
    }
    
    return timeline;
  }
}

/// Paginated orders response
class OrdersResponse {
  final List<Order> orders;
  final int page;
  final int limit;
  final int total;

  const OrdersResponse({
    required this.orders,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: (json['pagination']?['page'] as int?) ?? 1,
      limit: (json['pagination']?['limit'] as int?) ?? 20,
      total: (json['pagination']?['total'] as int?) ?? 0,
    );
  }

  bool get hasMore => orders.length < total;
  int get nextPage => page + 1;
}
